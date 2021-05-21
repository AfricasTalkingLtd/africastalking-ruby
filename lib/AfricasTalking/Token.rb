class Token
	include AfricasTalking
	HTTP_CREATED     = 201
	HTTP_OK          = 200

	#Set debug flag to to true to view response body
	def initialize username, apikey
		@username    = username
		@apikey      = apikey
	end

	def generateAuthToken
		post_body = {
			'username' => @username
		}
		url = getApiHost() + "/auth-token/generate"
		response = sendJSONRequest(url, post_body)
		# 
		if(@response_code == HTTP_CREATED)
			r=JSON.parse(response, :quirky_mode => true)
			return AuthTokenResponse.new r["token"], r["lifetimeInSeconds"]
		else
			raise AfricasTalkingException, response
		end
	end

	private

		def getApiHost()
			if(@username == "sandbox")
				return "https://api.sandbox.africastalking.com"
			else
				return "https://api.africastalking.com"
			end
		end
end

class AuthTokenResponse
	attr_accessor :token, :lifetimeInSeconds
	def initialize token_, lifetimeInSeconds_
		@token      = token_
		@lifetimeInSeconds = lifetimeInSeconds_
	end
end
