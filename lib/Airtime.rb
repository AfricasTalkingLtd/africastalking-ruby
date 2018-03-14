require "AfricasTalking/version"
require 'httparty'
require 'httmultiparty'
require 'json'
require "AfricasTalking"
require 'pry'

module AfricasTalking
	
	# /////////////////////////
	class Airtime < Gateway
		def initialize username, apikey, environment = nil
			@username    = username
			@apikey      = apikey
			@environment  = environment
		end

		def sendAirtime recipients
			r = recipients.to_json
			
			post_body = {
							'username'   => @username,
							'recipients' => r
						}
			url      = getAirtimeUrl() + "/send"
			response = executePost(url, post_body)
			# binding.pry
			if (@response_code == HTTP_CREATED)
				responses = JSON.parse(response, :quirky_mode =>true)['responses']
				if (responses.length > 0)
					results = responses.collect{ |result|
						AirtimeResult.new result['status'], result['phoneNumber'],result['amount'],result['requestId'], result['errorMessage'], result['discount']
					}
					return results
				else
					raise AfricasTalkingGatewayException, JSON.parse(response, :quirky_mode =>true)['errorMessage']
				end
			else
				raise AfricasTalkingGatewayException, response
			end
		end

		private
			def getAirtimeUrl()
				return getApiHost() + "/version1/airtime"
			end
	end
	class AirtimeResult
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
end