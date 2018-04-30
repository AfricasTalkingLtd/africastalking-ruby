class Payments
	include AfricasTalking
	HTTP_CREATED     = 201
	HTTP_OK          = 200
	#Set debug flag to to true to view response body
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
	def initialize username, apikey
		@username    = username
		@apikey      = apikey
	end

	def mobileCheckout options
		url      = getMobilePaymentCheckoutUrl()
		if validateParamsPresence?(options, ['productName', 'phoneNumber', 'currencyCode', 'amount', 'metadata'])
			parameters = {
				'username'     => @username,
				'productName'  => options['productName'],
				'phoneNumber'  => options['phoneNumber'],
				'currencyCode' => options['currencyCode'],
				'amount'       => options['amount'],
				'metadata'     => options['metadata']
			}
			response = sendJSONRequest(url, parameters)
		end

		if (@response_code == HTTP_CREATED)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			# 
			if (resultObj['status'] == 'PendingConfirmation')
				return MobileCheckoutResponse.new resultObj['status'], resultObj['description'], resultObj['transactionId'], resultObj['providerChannel']
			end
			raise AfricasTalkingGatewayException, resultObj['description']
		end
		raise AfricasTalkingGatewayException, response
	end

	def mobileB2B options
		validOptions = validateParamsPresence?(options, ['productName', 'providerData', 'currencyCode', 'amount', 'metadata'])
		validProviderData = validateParamsPresence?(options['providerData'], ['provider', 'destinationAccount', 'destinationChannel', 'transferType'])
		if validOptions && validProviderData
			parameters = {
				'username'           => @username,
				'productName'        => options['productName'],
				'provider'           => options['providerData']['provider'],
				'destinationChannel' => options['providerData']['destinationChannel'],
				'destinationAccount' => options['providerData']['destinationAccount'],
				'transferType'       => options['providerData']['transferType'],
				'currencyCode'       => options['currencyCode'],
				'amount'             => options['amount'],
				'metadata'           => options['metadata']
			}
			url      = getMobilePaymentB2BUrl()   
			response = sendJSONRequest(url, parameters)
		end

		if (@response_code == HTTP_CREATED)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			# 
			return MobileB2BResponse.new resultObj['status'], resultObj['transactionId'], resultObj['transactionFee'], resultObj['providerChannel']
		end
		raise AfricasTalkingGatewayException(response)
	end


	def mobileB2C options
		if validateParamsPresence?(options, ['recipients', 'productName'])
			parameters = {
				'username'    => @username,
				'productName' => options['productName'],
				'recipients'  => options['recipients']
			}
			url      = getMobilePaymentB2CUrl()
			response = sendJSONRequest(url, parameters)
		end
		if (@response_code == HTTP_CREATED)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			if (resultObj['entries'].length > 0)
				results = resultObj['entries'].collect{ |subscriber|
					MobileB2CResponse.new subscriber['provider'], subscriber['phoneNumber'], subscriber['providerChannel'], subscriber['transactionFee'], subscriber['status'], subscriber['value'], subscriber['transactionId']
				}
				# 
				return results
			end

			raise AfricasTalkingGatewayException, resultObj['errorMessage']
		end
		raise AfricasTalkingGatewayException, response
	end

	def bankCheckout options
		if validateParamsPresence?(options, ['bankAccount', 'productName', 'currencyCode', 'amount', 'narration', 'metadata'])
			parameters = {
				'username'    => @username,
				'productName' => options['productName'],
				'bankAccount'  => options['bankAccount'],
				'currencyCode' => options['currencyCode'],
				'amount' => options['amount'],
				'narration' => options['narration'],
				'metadata' => options['metadata']
			}
			url      = getBankChargeCheckoutUrl()
			response = sendJSONRequest(url, parameters)
		end
		if (@response_code == HTTP_CREATED)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			# 
			return InitiateBankCheckoutResponse.new resultObj['status'], resultObj['transactionId'], resultObj['description']
		end
		raise AfricasTalkingGatewayException(response)
	end	

	def validateBankCheckout options
		if validateParamsPresence?(options, ['transactionId', 'otp'])
			parameters = {
				'username'    => @username,
				'transactionId' => options['transactionId'],
				'otp'  => options['otp']
			}
			# 
			url      = getValidateBankCheckoutUrl()
			response = sendJSONRequest(url, parameters)
		end
		if (@response_code == HTTP_CREATED)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			return ValidateBankCheckoutResponse.new resultObj['status'], resultObj['description']
		end
		raise AfricasTalkingGatewayException(response)
	end

	def bankTransfer options
		if validateParamsPresence?(options, ['productName', 'recipients'])
			parameters = {
				'username'    => @username,
				'productName' => options['productName'],
				'recipients'  => options['recipients']
			}
			url      = getBankTransferRequestUrl()
			response = sendJSONRequest(url, parameters)		
		end
		if (@response_code == HTTP_CREATED)
			resultObj = JSON.parse(response, :quirky_mode =>true)

			if (resultObj['entries'].length > 0)
				results = resultObj['entries'].collect{ |item|
					BankTransferEntries.new item['accountNumber'], item['status'], item['transactionId'], item['transactionFee'], item['errorMessage']
				}
				

				return BankTransferResponse.new results, resultObj['errorMessage']
			end

			raise AfricasTalkingGatewayException, resultObj['errorMessage']
		end
		raise AfricasTalkingGatewayException, response
		
	end

	def cardCheckout options
		if validateParamsPresence?(options, ['productName', 'currencyCode', 'amount', 'narration', 'metadata'])
			parameters = {
				'username'    => @username,
				'productName' => options['productName'],
				'currencyCode' => options['currencyCode'],
				'amount' => options['amount'],
				'narration' => options['narration'],
				'metadata' => options['metadata']
			}
			if (options['checkoutToken'] == nil && options['paymentCard'] == nil)
				raise AfricasTalkingGatewayException "Please make sure either the checkoutToken or paymentCard parameter is not empty"
			elsif (options['checkoutToken'] != nil && options['paymentCard'] != nil)
				raise AfricasTalkingGatewayException "If you have a checkoutToken please make sure paymentCard parameter is empty"
			end
			if (options['checkoutToken'] != nil)
				parameters['checkoutToken'] = options['checkoutToken']
			end
			if (options['paymentCard'] != nil)
				parameters['paymentCard'] = options['paymentCard']
			end
			url      = getCardCheckoutChargeUrl()
			response = sendJSONRequest(url, parameters)
		end
		if (@response_code == HTTP_CREATED)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			# 
			return InitiateCardCheckoutResponse.new resultObj['status'], resultObj['description'], resultObj['transactionId']
		end
		raise AfricasTalkingGatewayException(response)

	end

	def validateCardCheckout options
		if validateParamsPresence?(options, ['transactionId', 'otp'])
			parameters = {
				'username'    => @username,
				'transactionId' => options['transactionId'],
				'otp'  => options['otp']
			}
			url      = getValidateCardCheckoutUrl()
			# 
			response = sendJSONRequest(url, parameters)
		end
		if (@response_code == HTTP_CREATED)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			return ValidateCardCheckoutResponse.new resultObj['status'], resultObj['description'], resultObj['checkoutToken']
			# 
		end
		raise AfricasTalkingGatewayException(response)
	end

	def walletTransferRequest options
		if validateParamsPresence?(options, ['productName', 'targetProductCode', 'currencyCode', 'amount', 'metadata'])
			parameters = {
				'username'    => @username,
				'productName' => options['productName'],
				'targetProductCode' => options['targetProductCode'],
				'currencyCode' => options['currencyCode'],
				'amount' => options['amount'],
				'metadata' => options['metadata'] 
			}
			url      = getWalletTransferUrl()
			response = sendJSONRequest(url, parameters)
		end
		if (@response_code == HTTP_CREATED)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			# 
			return WalletTransferResponse.new resultObj['status'], resultObj['description'], resultObj['transactionId']
		end
		raise AfricasTalkingGatewayException(response)
	end

	def topupStashRequest options
		if validateParamsPresence?(options, ['productName', 'currencyCode', 'amount', 'metadata'])
			parameters = {
				'username'    => @username,
				'productName' => options['productName'],
				'currencyCode' => options['currencyCode'],
				'amount' => options['amount'],
				'metadata' => options['metadata'] 
			}
			url      = getTopupStashUrl() 
			response = sendJSONRequest(url, parameters)
		end
		if (@response_code == HTTP_CREATED)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			return TopupStashResponse.new resultObj['status'], resultObj['description'], resultObj['transactionId']
		end
		raise AfricasTalkingGatewayException(response)
	end

	private

		def getPaymentHost()
			if(@username == "sandbox")
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
			if(@username == "sandbox")
				return "https://api.sandbox.africastalking.com"
			else
				return "https://api.africastalking.com"
			end
		end
		
end

class MobileB2CResponse
	attr_reader :provider, :phoneNumber, :providerChannel, :transactionFee, :status, :value, :transactionId

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
	attr_reader :status, :transactionId, :transactionFee, :providerChannel
			
	def initialize status_, transactionId_, transactionFee_, providerChannel_
			@providerChannel    = providerChannel_
			@transactionId = transactionId_
			@transactionFee  = transactionFee_
			@status          = status_
	end
end	

class BankTransferEntries
	attr_reader :accountNumber, :status, :transactionId, :transactionFee, :errorMessage
	def initialize accountNumber, status, transactionId, transactionFee, errorMessage
			@accountNumber = accountNumber
			@status = status
			@transactionId  = transactionId
			@transactionFee  = transactionFee
			@errorMessage   = errorMessage
	end
end

class BankTransferResponse
	attr_reader :entries, :errorMessage
	def initialize entries_, errorMessage_
			@entries = entries_
			@errorMessage   = errorMessage_
	end
end

class MobileCheckoutResponse
	attr_reader :status, :transactionFee, :transactionId, :providerChannel
	def initialize accountNumber_, status_, transactionId_, transactionFee_
			@accountNumber = accountNumber_
			@status = status_
			@transactionId  = transactionId_
			@transactionFee  = transactionFee_
	end
end
class InitiateBankCheckoutResponse
	attr_reader :status, :description, :transactionId
	def initialize status_, transactionId_, description_
			@description = description_
			@status = status_
			@transactionId  = transactionId_
	end
end
class ValidateBankCheckoutResponse
	attr_reader :status, :description
	def initialize status_, description_
			@description = description_
			@status = status_
	end
end

class InitiateCardCheckoutResponse
	attr_reader :status, :description, :transactionId
	def initialize status_, description_, transactionId_
			@description = description_
			@status = status_
			@transactionId = transactionId_
	end
end

class ValidateCardCheckoutResponse
	attr_reader :status, :description, :checkoutToken
	def initialize status_, description_, checkoutToken_
			@description = description_
			@status = status_
			@checkoutToken = checkoutToken_
	end
end

class WalletTransferResponse
	attr_reader :status, :description, :transactionId
	def initialize status_, description_, transactionId_
			@description = description_
			@status = status_
			@transactionId = transactionId_
	end
end

class TopupStashResponse
	attr_reader :status, :description, :transactionId
	def initialize status_, description_, transactionId_
			@description = description_
			@status = status_
			@transactionId = transactionId_
	end
end