require "AfricasTalking/version"
require 'httparty'
require 'httmultiparty'
require 'json'
require "AfricasTalking"
require 'pry'

module AfricasTalking
	
	# /////////////////////////
	class Airtime
		HTTP_CREATED     = 201
		HTTP_OK          = 200

		#Set debug flag to to true to view response body
		DEBUG            = true
		def initialize username, apikey
			@username    = username
			@apikey      = apikey
		end

		def sendAirtime options
			recipients = options.collect{ |r| r }
			post_body = {
							'username'   => @username,
							'recipients' => recipients.to_json
						}
			url      = getAirtimeUrl() + "/send"
			response = executePost(url, post_body)
			# binding.pry
			if (@response_code == HTTP_CREATED)
				responses = JSON.parse(response, :quirky_mode =>true)
				if (responses['responses'].length > 0)
					# binding.pry
					results = responses['responses'].collect{ |result|
						# binding.pry
						AirtimeResponse.new result['status'], result['phoneNumber'],result['amount'],result['requestId'], result['errorMessage'], result['discount']
					}
					# binding.pry
					return SendAirtimeResult.new responses["errorMessage"], responses["numSent"], responses["totalAmount"], responses["totalDiscount"], results
				else
					raise AfricasTalkingGatewayException, responses['errorMessage']
				end
			else
				raise AfricasTalkingGatewayException, response
			end
		end

		private
			def getAirtimeUrl()
				return getApiHost() + "/version1/airtime"
			end

			def getApiHost()
				if(@username == "sandbox")
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
	class AirtimeResponse
		attr_accessor :amount, :phoneNumber, :requestId, :status, :errorMessage, :discount
		def initialize(status_, number_, amount_, requestId_, errorMessage_, discount_)
			@status       = status_
			@phoneNumber  = number_
			@amount       = amount_
			@requestId    = requestId_
			@errorMessage = errorMessage_
			@discount     = discount_
		end
	end
	class SendAirtimeResult
		attr_accessor :errorMessage, :numSent, :totalAmount, :totalDiscount, :responses
		def initialize errorMessage_, numSent_, totalAmount_, totalDiscount_, responses_
			@errorMessage   = errorMessage_
			@numSent        = numSent_
			@totalAmount    = totalAmount_
			@totalDiscount  = totalDiscount_
			@responses      = responses_
		end
	end
end