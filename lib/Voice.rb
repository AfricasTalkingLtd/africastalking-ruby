require "AfricasTalking/version"
require 'httparty'
require 'httmultiparty'
require 'json'
require "AfricasTalking"
require 'pry'

module AfricasTalking
	
	# /////////////////////////
	class Voice
		HTTP_CREATED     = 201
		HTTP_OK          = 200

		#Set debug flag to to true to view response body
		DEBUG            = true

		def initialize username, apikey, environment = nil
			@username    = username
			@apikey      = apikey
			@environment  = environment
		end

		def call to, from
			post_body = {
				'username' => @username, 
				'from'     => from, 
				'to'       => to
			}
			# binding.pry
			response = executePost(getVoiceHost() + "/call", post_body)
			if(@response_code == HTTP_OK || @response_code == HTTP_CREATED)
				ob = JSON.parse(response, :quirky_mode => true)
				# binding.pry
				if (ob['entries'].length > 0)
					results = ob['entries'].collect{|result|
						CallEntries.new result['status'], result['phoneNumber']
					}
				end
				return CallResponse.new results, ob['errorMessage']
				# binding.pry
			else
				raise AfricasTalkingGatewayException, response
			end
		end

		def fetchQueuedCalls phoneNumber, queueName = nil
			post_body = {
				'username'    => @username,
				'phoneNumbers' => phoneNumber,
			}

			if (queueName != nil)
				post_body['queueName'] = queueName
			end

			url = getVoiceHost() + "/queueStatus"
			response = executePost(url, post_body)

			ob = JSON.parse(response, :quirky_mode => true)
			# binding.pry
			if(@response_code == HTTP_OK || @response_code == HTTP_CREATED)
				results = []
				if (ob['entries'].length > 0)
					results = ob['entries'].collect{|result|
						QueuedCalls.new result['phoneNumber'], result['numCalls'], result['queueName']
					}
				end
				# binding.pry
				return QueuedCallsResponse.new ob['status'], ob['errorMessage'], results
			end
			
			raise AfricasTalkingGatewayException, response
			
		end


		private
			def getVoiceHost()
				if(@environment == "sandbox")
					return "https://voice.sandbox.africastalking.com"
				else
					return "https://voice.africastalking.com"
				end
			end
			
			def getApiHost()
				if(@environment == "sandbox")
					return "https://api.sandbox.africastalking.com"
				else
					return "https://api.africastalking.com"
				end
			end

			def executePost(url_, data_ = nil)
				uri		 	     = URI.parse(url_)
				http		     = Net::HTTP.new(uri.host, uri.port)
				http.use_ssl     = true
				headers = {
				   "apikey" => @apikey,
				   "Accept" => "application/json"
				}
				if(data_ != nil)
					request = Net::HTTP::Post.new(uri.request_uri)
					request.set_form_data(data_)
				else
				    request = Net::HTTP::Get.new(uri.request_uri)
				end
				request["apikey"] = @apikey
				request["Accept"] = "application/json"
				response          = http.request(request)

				if (DEBUG)
					puts "Full response #{response.body}"
				end

				@response_code = response.code.to_i
				return response.body
			end
	end


	class CallResponse
		attr_accessor :errorMessage, :callentries

		def initialize(errorMessage_, callentries_)
			@errorMessage      = errorMessage_
			@callentries = callentries_
		end
	end

	class CallEntries
		attr_accessor :phoneNumber, :status

		def initialize(status_, number_)
			@status      = status_
			@phoneNumber = number_
		end
	end

	class QueuedCalls
		attr_accessor :numCalls, :phoneNumber, :queueName
		
		def initialize(number_, numCalls_, queueName_)
			@phoneNumber = number_
			@numCalls    = numCalls_
			@queueName   = queueName_
		end
	end

	class QueuedCallsResponse
		attr_accessor :status, :errorMessage, :queuedcalls

		def initialize(status_, errorMessage_, queuedcalls_)
			@status = status_
			@errorMessage    = errorMessage_
			@queuedcalls   = queuedcalls_
		end
	end
	
end