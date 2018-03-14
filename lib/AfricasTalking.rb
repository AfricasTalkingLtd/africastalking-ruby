require "AfricasTalking/version"
require 'httparty'
require 'httmultiparty'
require 'json'
require 'pry'
# require "Sms"

module AfricasTalking

	class Gateway
		attr_accessor :username, :apikey, :environment
		HTTP_CREATED     = 201
		HTTP_OK          = 200

		#Set debug flag to to true to view response body
		DEBUG            = true

		def initialize username, apikey, environment = nil
			@username    = username
			@apikey      = apikey
			@environment  = environment
			@response_code = nil
		end

		# //////////////////////SMS//////////////////////////
		def send_messages message, recipients, senderId = nil, enqueue = nil 
			at = AfricasTalking::Sms.new(@username, @apikey, @environment)
			sms = at.sendMessage message, recipients, senderId, enqueue
			# binding.pry
			return sms
			# returns StatusReport when successful
		end

		def fetch_messages lastReceivedId = nil
			at = AfricasTalking::Sms.new(@username, @apikey, @environment)
			sms = at.fetchMessages lastReceivedId
			# binding.pry
			return sms
			# returns SMSMessage when successful
		end

		def fetch_subscriptions shortCode, keyword, lastReceivedId = nil
			at = AfricasTalking::Sms.new(@username, @apikey, @environment)
			sms = at.fetchSubscriptions shortCode, keyword, lastReceivedId
			# binding.pry
			return sms
			# returns SMSMessage when successful
		end

		def create_subcriptions shortCode, keyword, phoneNumber, checkoutToken
			at = AfricasTalking::Sms.new(@username, @apikey, @environment)
			sms = at.createSubcriptions shortCode, keyword, phoneNumber, checkoutToken
			# binding.pry
			return sms
			# returns SMSMessage when successful
		end


		# /////////////////////////////////////////////////////

		# ///////////////////PAYMENTS//////////////////////////

		def initiate_mobile_payment_checkout productName, phoneNumber,  currencyCode, amount, metadata = {}
			at = AfricasTalking::Payments.new(@username, @apikey, @environment)
			payments = at.initiateMobilePaymentCheckout productName, phoneNumber, currencyCode, amount, metadata
			# binding.pry
			return payments	
		end		

		def mobile_b2c_request productName, recipients
			at = AfricasTalking::Payments.new(@username, @apikey, @environment)
			payments = at.mobilePaymentB2CRequest productName, recipients
			# binding.pry
			return payments			
		end

		def mobile_b2b_request productName, providerData, currencyCode, amount, metadata = {}
			at = AfricasTalking::Payments.new(@username, @apikey, @environment)
			payments = at.mobilePaymentB2BRequest productName, providerData, currencyCode, amount, metadata
			# binding.pry
			return payments			
		end

		def initiate_bank_charge_checkout  productName, bankAccount, currencyCode, amount, narration, metadata = {}
			at = AfricasTalking::Payments.new(@username, @apikey, @environment)
			payments = at.initiateBankChargeCheckout productName, bankAccount, currencyCode, amount, narration, metadata
			# binding.pry
			return payments	
		end

		def validate_bank_account_checkout transactionId, otp
			at = AfricasTalking::Payments.new(@username, @apikey, @environment)
			payments = at.validateBankAccountCheckout transactionId, otp
			# binding.pry
			return payments
		end

		def initiate_bank_transfer_request productName, recipients
			at = AfricasTalking::Payments.new(@username, @apikey, @environment)
			payments = at.initiateBankTransferRequest productName, recipients
			# binding.pry
			return payments	
		end

		def initiate_card_checkout productName, currencyCode, amount, narration, checkoutToken = nil, paymentCard = nil,  metadata = {}
			at = AfricasTalking::Payments.new(@username, @apikey, @environment)
			payments = at.initiateCardCheckout productName, currencyCode, amount, narration, checkoutToken, paymentCard, metadata
			# binding.pry
			return payments	
		end

		def validate_card_checkout transactionId, otp
			at = AfricasTalking::Payments.new(@username, @apikey, @environment)
			payments = at.validateCardCheckout transactionId, otp
			# binding.pry
			return payments	
		end

		def wallet_transfer_request productName, targetProductCode, currencyCode, amount, metadata
			at = AfricasTalking::Payments.new(@username, @apikey, @environment)
			payments = at.walletTransferRequest productName, targetProductCode, currencyCode, amount, metadata
			# binding.pry
			return payments	
		end

		def topup_stash_request productName, currencyCode, amount, metadata
			at = AfricasTalking::Payments.new(@username, @apikey, @environment)
			payments = at.topupStashRequest productName, currencyCode, amount, metadata
			# binding.pry
			return payments	
		end


		# /////////////////////////////////////////////////////


		# /////////////////////AIRTIME///////////////////////

		def send_airtime recipients
			at = AfricasTalking::Airtime.new @username, @apikey, @environment
			airtime = at.sendAirtime recipients
			return airtime
		end

		# /////////////////////////////////////////////////////


		# /////////////////////VOICE///////////////////////////

		def call to, from
			at = AfricasTalking::Voice.new @username, @apikey, @environment
			voice = at.call to, from
			return voice
		end

		def fetch_queued_calls to, from
			at = AfricasTalking::Voice.new @username, @apikey, @environment
			# binding.pry
			voice = at.fetchQueuedCalls to, from
			return voice
		end



		# /////////////////////////////////////////////////////


	
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


		def sendJSONRequest(url_, data_)
			uri	       = URI.parse(url_)
			http         = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			req          = Net::HTTP::Post.new(uri.request_uri, 'Content-Type'=>"application/json")
			
			req["apikey"] = @apikey
			req["Accept"] = "application/json"
			
			req.body = data_.to_json

			response  = http.request(req)
			
			if (DEBUG)
				puts "Full response #{response.body}"
			end

			@response_code = response.code.to_i
			return response.body
		end
	end

	class AfricasTalkingGatewayException < Exception
		# error handling appear here
		# def initialize(msg="My default message")
		#     super
		# end

		

	end

end
