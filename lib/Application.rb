class Application
	include AfricasTalking
	HTTP_CREATED     = 201
	HTTP_OK          = 200

	#Set debug flag to to true to view response body
	def initialize username, apikey
		@username    = username
		@apikey      = apikey
	end

	def fetchApplicationData
		url      = getUserDataUrl() + '?username='+@username+''
		response = sendNormalRequest(url)
		# 
		if (@response_code == HTTP_OK )
			result = JSON.parse(response, :quirky_mode =>true)
			return ApplicationDataResponse.new result["balance"]
		else
			raise AfricasTalkingGatewayException, response
		end
	end

	private

		def getUserDataUrl()
			return getApiHost() + "/version1/user"
		end

		def getApiHost()
			if(@username == "sandbox")
				return "https://api.sandbox.africastalking.com"
			else
				return "https://api.africastalking.com"
			end
		end
end
class ApplicationDataResponse
	attr_accessor :balance
	def initialize balance_
		@balance      = balance_
	end
end
