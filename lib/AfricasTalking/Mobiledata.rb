class Mobiledata
	include AfricasTalking
	HTTP_CREATED     = 201
	HTTP_OK          = 200

	def initialize username, apikey
		@username    = username
		@apikey      = apikey
	end

	def send options
		url      = getMobileDataUrl()

        validateParamsPresence? options, %w(productName)
		recipients = options['recipients'].map do |item|
            required_params = %w(phoneNumber quantity unit validity)
            if item['metadata'].is_a?(Hash)
                required_params << 'metadata'
              end

            validateParamsPresence?(item, required_params)
			item
		end

		post_body = {
			'username'   => @username,
            'productName' => options['productName'],
			'recipients' => recipients,
		}

		idempotency_key = options['idempotencyKey'].to_s if options['idempotencyKey']

		post_body['idempotencyKey'] = idempotency_key if idempotency_key

		response = sendJSONRequest(url, post_body, idempotency_key)

		if (@response_code == HTTP_CREATED)
			responses = JSON.parse(response, :quirky_mode =>true)

			if (responses['entries'].length > 0)

				results = responses['entries'].collect{ |data|

					MobileDataResponse.new data['phoneNumber'], data['provider'], data['status'], data['transactionId'], data['value']
				}

				return results
			else
				raise AfricasTalkingException, responses['errorMessage']
			end
			raise AfricasTalkingException, response
		end
	end

    def findTransaction options
		validateParamsPresence? options, ['transactionId']
		parameters = {
			'username'    => @username,
			'transactionId' => options['transactionId']
		}
		url      = getFindTransactionUrl()
		response = sendJSONRequest(url, parameters, true, false)
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
		response = sendJSONRequest(url, parameters, true, false)
		if (@response_code == HTTP_OK)
			resultObj = JSON.parse(response, :quirky_mode =>true)

			return FetchWalletBalanceResponse.new resultObj['status'], resultObj['balance']
		end
		raise AfricasTalkingException, response
	end

	private
		def getMobileDataUrl()
			return getApiHost() + "/mobile/data/request"
		end

        def getFindTransactionUrl()
			return getApiHost() + "/query/transaction/find"
		end

        def getFetchWalletBalanceUrl()
			return getApiHost() + "/query/wallet/balance"
		end

		def getApiHost()
			if(@username == "sandbox")
				return "https://bundles.sandbox.africastalking.com"
			else
				return "https://bundles.africastalking.com"
			end
		end
end

class MobileDataResponse
	attr_reader :phoneNumber, :provider, :status, :transactionId, :value

	def initialize phoneNumber_, provider_, status_, transactionId_, value_
			@phoneNumber     = phoneNumber_
			@provider        = provider_
			@status          = status_
            @transactionId   = transactionId_
			@value           = value_
	end
end

class FetchWalletBalanceResponse
	attr_reader :status, :balance
	def initialize status_, balance_
		@status = status_
		@balance = balance_
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