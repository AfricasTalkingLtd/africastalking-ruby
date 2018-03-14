require "AfricasTalking/version"
require 'httparty'
require 'httmultiparty'
require 'json'
require "AfricasTalking"
require 'pry'

module AfricasTalking
	
	# /////////////////////////
	class Voice < Gateway
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
			response = executePost(getVoiceHost() + "/call", post_body)
			if(@response_code == HTTP_OK || @response_code == HTTP_CREATED)
				ob = JSON.parse(response, :quirky_mode => true)
				# binding.pry
				if (ob['errorMessage'] == "None")
					results = ob['entries'].collect{|result|
						CallResponse.new result['status'], result['phoneNumber']
					}
					return results
				else
					raise AfricasTalkingGatewayException, ob['errorMessage']
				end
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
				if (ob['errorMessage'] == "None")
					results = ob['entries'].collect{|result|
						QueuedCalls.new result['phoneNumber'], result['numCalls'], result['queueName']
					}
					return results
				end

				raise AfricasTalkingGatewayException, ob['errorMessage']
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
			
	end

	class CallResponse
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
	
end