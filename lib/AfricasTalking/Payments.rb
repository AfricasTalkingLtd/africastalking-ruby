class Payments
	include AfricasTalking
	HTTP_CREATED     = 201
	HTTP_OK          = 200
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
	PROVIDERS = {
		'MPESA'   => 'Mpesa',
		'SEGOVIA' => 'Segovia',
		'FLUTTERWAVE' => 'Flutterwave',
		'ADMIN' => 'Admin',
		'ATHENA' => 'Athena',
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
			raise AfricasTalkingException, resultObj['description']
		end
		raise AfricasTalkingException, response
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
			return MobileB2BResponse.new resultObj['status'], resultObj['transactionId'], resultObj['transactionFee'], resultObj['providerChannel'], resultObj['errorMessage']
		end
		raise AfricasTalkingException, response
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
					MobileB2CResponse.new subscriber['provider'], subscriber['phoneNumber'], subscriber['providerChannel'], subscriber['transactionFee'], subscriber['status'], subscriber['value'], subscriber['transactionId'], subscriber['errorMessage']
				}
				# 
				return results
			end

			raise AfricasTalkingException, resultObj['errorMessage']
		end
		raise AfricasTalkingException, response
	end

	def bankCheckoutCharge options
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
		raise AfricasTalkingException, response
	end	

	def bankCheckoutValidate options
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
		raise AfricasTalkingException, response
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

			raise AfricasTalkingException, resultObj['errorMessage']
		end
		raise AfricasTalkingException, response
		
	end

	def cardCheckoutCharge options
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
				raise AfricasTalkingException, "Please make sure either the checkoutToken or paymentCard parameter is not empty"
			elsif (options['checkoutToken'] != nil && options['paymentCard'] != nil)

				raise AfricasTalkingException, "If you have a checkoutToken please make sure paymentCard parameter is empty"
			end
			if (options['checkoutToken'] != nil)
				parameters['checkoutToken'] = options['checkoutToken']
			end
			if (options['paymentCard'] != nil)
				if validateParamsPresence?(options['paymentCard'], ['number', 'cvvNumber', 'expiryMonth', 'expiryYear', 'countryCode', 'authToken'])
					parameters['paymentCard'] = options['paymentCard']
				end
			end
			url      = getCardCheckoutChargeUrl()
			response = sendJSONRequest(url, parameters)
		end
		if (@response_code == HTTP_CREATED)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			# 
			return InitiateCardCheckoutResponse.new resultObj['status'], resultObj['description'], resultObj['transactionId']
		end
		raise AfricasTalkingException, response

	end

	def cardCheckoutValidate options
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
		raise AfricasTalkingException, response
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
		raise AfricasTalkingException, response
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
		raise AfricasTalkingException, response
	end

	def fetchProductTransactions options
		validateParamsPresence? options, %w(productName filters)
		filters = options['filters']
		validateParamsPresence? filters, %w(pageNumber count)
		parameters = {
			'username'    => @username,
			'productName' => options['productName'],
			'pageNumber' => filters['pageNumber'],
			'count' => filters['count']
		}
		parameters['startDate'] = filters['startDate'] if !(filters['startDate'].nil? || filters['startDate'].empty?)
		parameters['endDate'] = filters['endDate'] if !(filters['endDate'].nil? || filters['endDate'].empty?)
		parameters['category'] = filters['category'] if !(filters['category'].nil? || filters['category'].empty?)
		parameters['status'] = filters['status'] if !(filters['status'].nil? || filters['status'].empty?)
		parameters['source'] = filters['source'] if !(filters['source'].nil? || filters['source'].empty?)
	 	parameters['destination'] = filters['destination'] if !(filters['destination'].nil? || filters['destination'].empty?)
		parameters['providerChannel'] = filters['providerChannel'] if !(filters['providerChannel'].nil? || filters['providerChannel'].empty?)
		url      = getFetchTransactionsUrl() 
		response = sendJSONRequest(url, parameters, true)
		if (@response_code == HTTP_OK)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			results = []
			if (resultObj['responses'].length > 0)
				results = resultObj['responses'].collect{ |item|
					FetchTransactionsEntries.new item['sourceType'], item['source'], item['provider'], item['destinationType'], item['description'], item['providerChannel'], item['providerMetadata'],
					item['status'], item['productName'], item['category'], item['destination'], item['value'], item['transactionId'], item['creationTime'], item['requestMetadata']  
				}
			end
			return FetchTransactionsResponse.new resultObj['status'], resultObj['description'], results
		end
		raise AfricasTalkingException, response
	end

	def fetchWalletTransactions options
		validateParamsPresence? options %w(filters)
		filters = options['filters']
		validateParamsPresence? filters, %w(pageNumber count)
		parameters = {
			'username'    => @username,
			'pageNumber' => filters['pageNumber'],
			'count' => filters['count']
		}
		if !(filters['startDate'].nil? || filters['startDate'].empty?)
			parameters['startDate'] = filters['startDate']
		end
		if !(filters['endDate'].nil? || filters['endDate'].empty?)
			parameters['endDate'] = filters['endDate']
		end
		if !(filters['categories'].nil? || filters['categories'].empty?)
			parameters['categories'] = filters['categories']
		end
		url      = getFetchWalletUrl() 
		response = sendJSONRequest(url, parameters, true)
		if (@response_code == HTTP_OK)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			results = []
			if (resultObj['responses'].length > 0)
				results = resultObj['responses'].collect{ |item|
					transactionData = TransactionData.new item['transactionData']['requestMetadata'], item['transactionData']['sourceType'],
					item['transactionData']['source'], item['transactionData']['provider'], item['transactionData']['destinationType'],item['transactionData']['description'],
					item['transactionData']['providerChannel'], item['transactionData']['providerRefId'], item['transactionData']['providerMetadata'],item['transactionData']['status'],
					item['transactionData']['productName'], item['transactionData']['category'], item['transactionData']['transactionDate'], item['transactionData']['destination'],
					item['transactionData']['value'], item['transactionData']['transactionId'], item['transactionData']['creationTime']
					FetchWalletEntries.new item['description'], item['balance'], item['date'], item['category'], item['value'], item['transactionId'], transactionData 
				}
			end
			return FetchWalletResponse.new resultObj['status'], resultObj['description'], results
		end
		raise AfricasTalkingException, response
	end

	def findTransaction options
		if validateParamsPresence?(options, ['transactionId'])
			parameters = {
				'username'    => @username,
				'transactionId' => options['transactionId']
			}
			url      = getFindTransactionUrl() 
			response = sendJSONRequest(url, parameters, true)
		end
		if (@response_code == HTTP_OK)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			transactionData = nil
			if resultObj['status'] === 'Success'
				transactionData = TransactionData.new resultObj['data']['requestMetadata'], resultObj['data']['sourceType'],resultObj['data']['source'], resultObj['data']['provider'], resultObj['data']['destinationType'],resultObj['data']['description'],
					resultObj['data']['providerChannel'], resultObj['data']['providerRefId'], resultObj['data']['providerMetadata'],resultObj['data']['status'], resultObj['data']['productName'], resultObj['data']['category'], 
					resultObj['data']['transactionDate'], resultObj['data']['destination'], resultObj['data']['value'], resultObj['data']['transactionId'], resultObj['data']['creationTime']
			end
			return FindTransactionResponse.new resultObj['status'], transactionData
		end
		raise AfricasTalkingException, response
	end

	def fetchWalletBalance
		parameters = { 'username' => @username }
		url        = getFetchWalletBalanceUrl()
		response = sendJSONRequest(url, parameters, true)
		if (@response_code == HTTP_OK)
			resultObj = JSON.parse(response, :quirky_mode =>true)
			
			return FetchWalletBalanceResponse.new resultObj['status'], resultObj['balance']
		end
		raise AfricasTalkingException, response
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

		def getFetchWalletUrl()
			return getPaymentHost() + "/query/wallet/fetch"
		end

		def getFetchWalletBalanceUrl()
			return getPaymentHost() + "/query/wallet/balance"
		end

		def getFetchTransactionsUrl()
			return getPaymentHost() + "/query/transaction/fetch"
		end

		def getFindTransactionUrl()
			return getPaymentHost() + "/query/transaction/find"
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
	attr_reader :provider, :phoneNumber, :providerChannel, :transactionFee, :status, :value, :transactionId, :errorMessage

	def initialize provider_, phoneNumber_, providerChannel_, transactionFee_, status_, value_, transactionId_, errorMessage_
			@provider        = provider_
			@phoneNumber     = phoneNumber_
			@providerChannel = providerChannel_
			@transactionFee  = transactionFee_
			@status          = status_
			@value           = value_
			@transactionId   = transactionId_
			@errorMessage   = errorMessage_
	end
end	

class MobileB2BResponse
	attr_reader :status, :transactionId, :transactionFee, :providerChannel, :errorMessage
			
	def initialize status_, transactionId_, transactionFee_, providerChannel_, errorMessage_
			@providerChannel    = providerChannel_
			@transactionId = transactionId_
			@transactionFee  = transactionFee_
			@status          = status_
			@errorMessage   = errorMessage_
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
	attr_reader :status, :description, :transactionId, :providerChannel
	def initialize status_, description_, transactionId_, providerChannel_
			@description = description_
			@status = status_
			@transactionId  = transactionId_
			@providerChannel  = providerChannel_
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

class FetchTransactionsEntries
	attr_reader :sourceType, :source, :provider, :destinationType, :description, :providerChannel, 
	:providerMetadata, :status, :productName, :category, :destination, :value, :transactionId, :creationTime, :requestMetadata

	def initialize sourceType_, source_, provider_, destinationType_, description_, providerChannel_, providerMetadata_, status_, productName_, category_, destination_, value_, transactionId_, creationTime_, requestMetadata_
		@sourceType = sourceType_
		@source = source_
		@provider = provider_
		@destinationType = destinationType_
		@description = description_
		@providerChannel = providerChannel_
		@providerMetadata = providerMetadata_
		@status = status_
		@productName = productName_
		@category = category_
		@destination = destination_
		@value = value_
		@transactionId = transactionId_
		@creationTime = creationTime_
		@requestMetadata = requestMetadata_ 
	end
end

class FetchTransactionsResponse
	attr_reader :status, :description, :entries
	def initialize status_, description_, entries_
		@description = description_
		@status = status_
		@entries = entries_
	end
end

class FetchWalletBalanceResponse
	attr_reader :status, :balance
	def initialize status_, balance_
		@status = status_
		@balance = balance_
	end
end

class FetchWalletResponse
	attr_reader :status, :description, :responses
	def initialize status_, description_, responses_
		@description = description_
		@status = status_
		@responses = responses_
	end
end

class FetchWalletEntries 
	attr_reader :description, :balance, :date, :category, :value, :transactionId, :transactionData
	def initialize description_, balance_, date_, category_, value_, transactionId_, transactionData_
		@description = description_
		@balance = balance_
		@date = date_
		@category = category_
		@value = value_
		@transactionId = transactionId_
		@transactionData = transactionData_
	end
end

class FindTransactionResponse
	attr_reader :status, :transactionData
	def initialize status_, transactionData_
		@status = status_
		@transactionData = transactionData_
	end
end

class TransactionData
	attr_reader :requestMetadata, :sourceType, :source, :provider, :destinationType, :description, :providerChannel, :providerRefId, :providerMetadata, :status, :productName, :category, :transactionDate, :destination, :value, :transactionId, :creationTime
	def initialize requestMetadata_, sourceType_, source_, provider_, destinationType_, description_, providerChannel_, providerRefId_, providerMetadata_, status_, productName_, category_, transactionDate_, destination_, value_, transactionId_, creationTime_
		@requestMetadata =requestMetadata_
		@sourceType = sourceType_
		@source = source_
		@provider = provider_
		@destinationType = destinationType_
		@description = description_
		@providerChannel = providerChannel_
		@providerRefId = providerRefId_
		@providerMetadata = providerMetadata_
		@status = status_
		@productName = productName_
		@category = category_
		@transactionDate = transactionDate_
		@destination = destination_
		@value = value_
		@transactionId = transactionId_
		@creationTime = creationTime_
	end
end