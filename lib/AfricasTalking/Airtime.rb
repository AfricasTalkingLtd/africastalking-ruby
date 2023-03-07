class Airtime
	include AfricasTalking
	HTTP_CREATED     = 201
	HTTP_OK          = 200

	#Set debug flag to to true to view response body
	def initialize username, apikey
		@username    = username
		@apikey      = apikey
	end

	def send options
		url      = getAirtimeUrl() + "/send"

		recipients = options['recipients'].each{|item| 
			validateParamsPresence? item, %w(phoneNumber currencyCode amount)
			item['amount'].to_s.prepend(item['currencyCode'].to_s + " ") 
			item.delete('currencyCode')
		}
		post_body = {
			'username'   => @username,
			'recipients' => recipients.to_json,
		}

		if options['maxNumRetry'] && options['maxNumRetry'] > 0
            post_body['maxNumRetry'] = options['maxNumRetry'].to_i

        else
            puts "Please make sure #{options['maxNumRetry']} is a number and greater than zero!"
        end

		response = sendNormalRequest(url, post_body) 
		if (@response_code == HTTP_CREATED)
			responses = JSON.parse(response, :quirky_mode =>true)
			if (responses['responses'].length > 0)
				# 
				results = responses['responses'].collect{ |result|
					# 
					AirtimeResponse.new result['status'], result['phoneNumber'],result['amount'],result['requestId'], result['errorMessage'], result['discount']
				}
				# 
				return SendAirtimeResult.new responses["errorMessage"], responses["numSent"], responses["totalAmount"], responses["totalDiscount"], results
			else
				raise AfricasTalkingException, responses['errorMessage']
			end
			raise AfricasTalkingException, response
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
end
class AirtimeResponse
	attr_reader :amount, :phoneNumber, :requestId, :status, :errorMessage, :discount
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
	attr_reader :errorMessage, :numSent, :totalAmount, :totalDiscount, :responses
	def initialize errorMessage_, numSent_, totalAmount_, totalDiscount_, responses_
		@errorMessage   = errorMessage_
		@numSent        = numSent_
		@totalAmount    = totalAmount_
		@totalDiscount  = totalDiscount_
		@responses      = responses_
	end
end