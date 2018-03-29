require "AfricasTalking/version"
require 'httparty'
require 'httmultiparty'
require 'json'
require "AfricasTalking"
require 'pry'

module AfricasTalking
	
	# /////////////////////////
	class Payments

		HTTP_CREATED     = 201
		HTTP_OK          = 200

		#Set debug flag to to true to view response body
		DEBUG            = true

		BANK_CODES = {
	      'FCMB_NG' => 234001,
	      'ZENITH_NG' => 234002,
	      'ACCESS_NG' => 234003,
	      'GTBANK_NG' => 234004,
	      'ECOBANK_NG' => 234005,
	      'DIAMOND_NG' => 234006,
	      'PROVIDUS_NG' => 234007,
	      'UNITY_NG' => 234008,
	      'STANBIC_NG' => 234009,
	      'STERLING_NG' => 234010,
	      'PARKWAY_NG' => 234011,
	      'AFRIBANK_NG' => 234012,
	      'ENTREPRISE_NG' => 234013,
	      'FIDELITY_NG' => 234014,
	      'HERITAGE_NG' => 234015,
	      'KEYSTONE_NG' => 234016,
	      'SKYE_NG' => 234017,
	      'STANCHART_NG' => 234018,
	      'UNION_NG' => 234019,
	      'UBA_NG' => 234020,
	      'WEMA_NG' => 234021,
	      'FIRST_NG' => 234022,
		}
		def initialize username, apikey, environment = nil
			@username    = username
			@apikey      = apikey
			@environment  = environment
		end

		def initiateMobilePaymentCheckout(productName_, phoneNumber_,  currencyCode_, amount_, metadata_ = {})
			parameters = {
				'username'     => @username,
				'productName'  => productName_,
				'phoneNumber'  => phoneNumber_,
				'currencyCode' => currencyCode_,
				'amount'       => amount_,
				'metadata'     => metadata_
			}
			
			url      = getMobilePaymentCheckoutUrl()
			response = sendJSONRequest(url, parameters)
			
			if (@response_code == HTTP_CREATED)
				resultObj = JSON.parse(response, :quirky_mode =>true)
				# binding.pry
				if (resultObj['status'] == 'PendingConfirmation')
					return MobileCheckoutResponse.new resultObj['status'], resultObj['description'], resultObj['transactionId'], resultObj['providerChannel']
				end
				raise AfricasTalkingGatewayException, resultObj['description']
			end
			raise AfricasTalkingGatewayException, response
		end

		def mobilePaymentB2BRequest(productName_, providerData_, currencyCode_, amount_, metadata_ = {})
			if (!providerData_.key?('provider'))
				raise AfricasTalkingGatewayException("Missing field provider")
			end
				
			if (!providerData_.key?('destinationChannel'))
				raise AfricasTalkingGatewayException("Missing field destinationChannel")
			end

			if (!providerData_.key?('destinationAccount'))
				raise AfricasTalkingGatewayException("Missing field destinationAccount")
			end
			
			if (!providerData_.key?('transferType'))
				raise AfricasTalkingGatewayException("Missing field transferType")
			end
			
			parameters = {
			              'username'           => @username,
			              'productName'        => productName_,
			              'provider'           => providerData_['provider'],
			              'destinationChannel' => providerData_['destinationChannel'],
			              'destinationAccount' => providerData_['destinationAccount'],
			              'transferType'       => providerData_['transferType'],
			              'currencyCode'       => currencyCode_,
			              'amount'             =>amount_,
			              'metadata'           =>metadata_
			}
			
			url      = getMobilePaymentB2BUrl()
			response = sendJSONRequest(url, parameters)
			
			if (@response_code == HTTP_CREATED)
				resultObj = JSON.parse(response, :quirky_mode =>true)
				# binding.pry
				return MobileB2BResponse.new resultObj['status'], resultObj['transactionId'], resultObj['transactionFee'], resultObj['providerChannel']
			end
			raise AfricasTalkingGatewayException(response)
		end


		def mobilePaymentB2CRequest(productName_, recipients_)
			parameters = {
				'username'    => @username,
				'productName' => productName_,
				'recipients'  => recipients_
			}
			# binding.pry
			url      = getMobilePaymentB2CUrl()
			response = sendJSONRequest(url, parameters)

			
			
			if (@response_code == HTTP_CREATED)
				resultObj = JSON.parse(response, :quirky_mode =>true)
				if (resultObj['entries'].length > 0)
					results = resultObj['entries'].collect{ |subscriber|
						MobileB2CResponse.new subscriber['provider'], subscriber['phoneNumber'], subscriber['providerChannel'], subscriber['transactionFee'], subscriber['status'], subscriber['value'], subscriber['transactionId']
					}
					# binding.pry
					return results
				end

				raise AfricasTalkingGatewayException, resultObj['errorMessage']
			end
			raise AfricasTalkingGatewayException, response
		end

		def initiateBankChargeCheckout productName, bankAccount, currencyCode, amount, narration, metadata = {}

			parameters = {
				'username'    => @username,
				'productName' => productName,
				'bankAccount'  => bankAccount,
				'currencyCode' => currencyCode,
				'amount' => amount,
				'narration' => narration,
				'metadata' => metadata
			}
			url      = getBankChargeCheckoutUrl()
			response = sendJSONRequest(url, parameters)

			if (@response_code == HTTP_CREATED)
				resultObj = JSON.parse(response, :quirky_mode =>true)
				# binding.pry
				return InitiateBankCheckoutResponse.new resultObj['status'], resultObj['transactionId'], resultObj['description']
			end
			raise AfricasTalkingGatewayException(response)
			
		end	

		def validateBankAccountCheckout transactionId, otp
			parameters = {
				'username'    => @username,
				'transactionId' => transactionId,
				'otp'  => otp
			}
			# binding.pry
			url      = getValidateBankCheckoutUrl()
			response = sendJSONRequest(url, parameters)

			if (@response_code == HTTP_CREATED)
				resultObj = JSON.parse(response, :quirky_mode =>true)
				return ValidateBankCheckoutResponse.new resultObj['status'], resultObj['description']
			end
			raise AfricasTalkingGatewayException(response)
		end

		def initiateBankTransferRequest productName, recipients
			parameters = {
				'username'    => @username,
				'productName' => productName,
				'recipients'  => recipients
			}
			
			url      = getBankTransferRequestUrl()
			response = sendJSONRequest(url, parameters)		

			if (@response_code == HTTP_CREATED)
				resultObj = JSON.parse(response, :quirky_mode =>true)

				if (resultObj['entries'].length > 0)
					results = resultObj['entries'].collect{ |subscriber|
						BankTransferEntries.new subscriber['accountNumber'], subscriber['status'], subscriber['transactionId'], subscriber['transactionFee'], subscriber['errorMessage']
					}
					

					return BankTransferResponse.new results, resultObj['errorMessage']
				end

				raise AfricasTalkingGatewayException, resultObj['errorMessage']
			end
			raise AfricasTalkingGatewayException, response
			
		end

		def initiateCardCheckout productName, currencyCode, amount, narration, checkoutToken = nil, paymentCard = nil, metadata = {}
			
			parameters = {
				'username'    => @username,
				'productName' => productName,
				'currencyCode' => currencyCode,
				'amount' => amount,
				'narration' => narration,
				'metadata' => metadata
			}
			# binding.pry
			if (checkoutToken == nil && paymentCard == nil)
				raise AfricasTalkingGatewayException "Please make sure either the checkoutToken or paymentCard parameter is not empty"
			elsif (checkoutToken != nil && paymentCard != nil)
				raise AfricasTalkingGatewayException "If you have a checkoutToken please make sure paymentCard parameter is empty"
			end
			if (checkoutToken != nil)
				parameters['checkoutToken'] = checkoutToken
			end

			if (paymentCard != nil)
				parameters['paymentCard'] = paymentCard
			end
			
			url      = getCardCheckoutChargeUrl()
			# binding.pry
			response = sendJSONRequest(url, parameters)

			if (@response_code == HTTP_CREATED)
				resultObj = JSON.parse(response, :quirky_mode =>true)
				# binding.pry
				return InitiateCardCheckoutResponse.new resultObj['status'], resultObj['description'], resultObj['transactionId']
			end
			raise AfricasTalkingGatewayException(response)

		end

		def validateCardCheckout transactionId, otp
			parameters = {
				'username'    => @username,
				'transactionId' => transactionId,
				'otp' => otp
			}

			url      = getValidateCardCheckoutUrl()
			# binding.pry
			response = sendJSONRequest(url, parameters)

			if (@response_code == HTTP_CREATED)
				resultObj = JSON.parse(response, :quirky_mode =>true)
				return ValidateCardCheckoutResponse.new resultObj['status'], resultObj['description'], resultObj['checkoutToken']
				# binding.pry
			end
			raise AfricasTalkingGatewayException(response)
		end

		def walletTransferRequest productName, targetProductCode, currencyCode, amount, metadata
			parameters = {
				'username'    => @username,
				'productName' => productName,
				'targetProductCode' => targetProductCode,
				'currencyCode' => currencyCode,
				'amount' => amount,
				'metadata' => metadata 
			}

			url      = getWalletTransferUrl()
			# binding.pry
			response = sendJSONRequest(url, parameters)

			if (@response_code == HTTP_CREATED)
				resultObj = JSON.parse(response, :quirky_mode =>true)
				# binding.pry
				return WalletTransferResponse.new resultObj['status'], resultObj['description'], resultObj['transactionId']
			end
			raise AfricasTalkingGatewayException(response)
		end

		def topupStashRequest productName, currencyCode, amount, metadata
			parameters = {
				'username'    => @username,
				'productName' => productName,
				'currencyCode' => currencyCode,
				'amount' => amount,
				'metadata' => metadata 
			}

			url      = getTopupStashUrl()
			# binding.pry
			response = sendJSONRequest(url, parameters)

			if (@response_code == HTTP_CREATED)
				resultObj = JSON.parse(response, :quirky_mode =>true)
				return TopupStashResponse.new resultObj['status'], resultObj['description'], resultObj['transactionId']
			end
			raise AfricasTalkingGatewayException(response)
		end

		private
			def getPaymentHost()
				if(@environment == "sandbox")
					return "https://payments.sandbox.africastalking.com"
				else
					return "https://payments.africastalking.com"
				end
			end

			def getMobilePaymentCheckoutUrl()
				return getPaymentHost() + "/mobile/checkout/request"
			end

			def getMobilePaymentB2CUrl()
				return getPaymentHost() + "/mobile/b2c/request"
			end

			def getMobilePaymentB2BUrl()
				return getPaymentHost() + "/mobile/b2b/request"
			end

			def getBankChargeCheckoutUrl()
				return getPaymentHost() + "/bank/checkout/charge"
			end

			def getValidateBankCheckoutUrl()
				return getPaymentHost() + "/bank/checkout/validate"
			end

			def getBankTransferRequestUrl()
				return getPaymentHost() + "/bank/transfer"
			end

			def getCardCheckoutChargeUrl()
				return getPaymentHost() + "/card/checkout/charge"
			end

			def getValidateCardCheckoutUrl()
				return getPaymentHost() + "/card/checkout/validate"
			end

			def getWalletTransferUrl()
				return getPaymentHost() + "/transfer/wallet"
			end

			def getTopupStashUrl()
				return getPaymentHost() + "/topup/stash"
			end

			def getApiHost()
				if(@environment == "sandbox")
					return "https://api.sandbox.africastalking.com"
				else
					return "https://api.africastalking.com"
				end
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
	
	class MobileB2CResponse
		attr_accessor :provider, :phoneNumber, :providerChannel, :transactionFee, :status, :value, :transactionId

		def initialize provider_, phoneNumber_, providerChannel_, transactionFee_, status_, value_, transactionId_
				@provider        = provider_
				@phoneNumber     = phoneNumber_
				@providerChannel = providerChannel_
				@transactionFee  = transactionFee_
				@status          = status_
				@value           = value_
				@transactionId   = transactionId_
		end
	end	

	class MobileB2BResponse
		attr_accessor :status, :transactionId, :transactionFee, :providerChannel
				
		def initialize status_, transactionId_, transactionFee_, providerChannel_
				@providerChannel    = providerChannel_
				@transactionId = transactionId_
				@transactionFee  = transactionFee_
				@status          = status_
		end
	end	

	class BankTransferEntries
		attr_accessor :accountNumber, :status, :transactionId, :transactionFee, :errorMessage
		def initialize accountNumber, status, transactionId, transactionFee, errorMessage
				@accountNumber = accountNumber
				@status = status
				@transactionId  = transactionId
				@transactionFee  = transactionFee
				@errorMessage   = errorMessage
		end
	end

	class BankTransferResponse
		attr_accessor :entries, :errorMessage
		def initialize entries_, errorMessage_
				@entries = entries_
				@errorMessage   = errorMessage_
		end
	end

	class MobileCheckoutResponse
		attr_accessor :status, :transactionFee, :transactionId, :providerChannel
		def initialize accountNumber_, status_, transactionId_, transactionFee_
				@accountNumber = accountNumber_
				@status = status_
				@transactionId  = transactionId_
				@transactionFee  = transactionFee_
		end
	end
	class InitiateBankCheckoutResponse
		attr_accessor :status, :description, :transactionId
		def initialize status_, transactionId_, description_
				@description = description_
				@status = status_
				@transactionId  = transactionId_
		end
	end
	class ValidateBankCheckoutResponse
		attr_accessor :status, :description
		def initialize status_, description_
				@description = description_
				@status = status_
		end
	end

	class InitiateCardCheckoutResponse
		attr_accessor :status, :description, :transactionId
		def initialize status_, description_, transactionId_
				@description = description_
				@status = status_
				@transactionId = transactionId_
		end
	end

	class ValidateCardCheckoutResponse
		attr_accessor :status, :description, :checkoutToken
		def initialize status_, description_, checkoutToken_
				@description = description_
				@status = status_
				@checkoutToken = checkoutToken_
		end
	end

	class WalletTransferResponse
		attr_accessor :status, :description, :transactionId
		def initialize status_, description_, transactionId_
				@description = description_
				@status = status_
				@transactionId = transactionId_
		end
	end

	class TopupStashResponse
		attr_accessor :status, :description, :transactionId
		def initialize status_, description_, transactionId_
				@description = description_
				@status = status_
				@transactionId = transactionId_
		end
	end
end