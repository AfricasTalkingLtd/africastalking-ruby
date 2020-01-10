class Voice
	include AfricasTalking
	HTTP_CREATED     = 201
	HTTP_OK          = 200

	#Set debug flag to to true to view response body

	def initialize username, apikey
		@username    = username
		@apikey      = apikey
	end

	def call options
		if validateParamsPresence?(options, ['from', 'to'])
			post_body = {
				'username'              => @username,
				'from'                  => options['from'],
				'to'                    => options['to'],
				'clientRequestId'       => options['clientRequestId']
			}
			# 
			response = sendNormalRequest(getVoiceHost() + "/call", post_body)
		end
		if(@response_code == HTTP_OK || @response_code == HTTP_CREATED)
			ob = JSON.parse(response, :quirky_mode => true)
			# 
			if (ob['entries'].length > 0)
				results = ob['entries'].collect{|result|
					CallEntries.new result['status'], result['phoneNumber']
				}
			end
			return CallResponse.new results, ob['errorMessage']
			# 
		else
			raise AfricasTalkingException, response
		end
	end

	def fetchQueuedCalls options
		if validateParamsPresence?(options, ['phoneNumber'])
			post_body = {
				'username'    => @username,
				'phoneNumbers' => options['phoneNumber'],
			}

			url = getVoiceHost() + "/queueStatus"
			response = sendNormalRequest(url, post_body)
		end
		# 
		if(@response_code == HTTP_OK || @response_code == HTTP_CREATED)
			ob = JSON.parse(response, :quirky_mode => true)
			results = []
			if (ob['entries'].length > 0)
				results = ob['entries'].collect{|result|
					QueuedCalls.new result['phoneNumber'], result['numCalls'], result['queueName']
				}
			end
			# 
			return QueuedCallsResponse.new ob['status'], ob['errorMessage'], results
		end
		
		raise AfricasTalkingException, response
		
	end

	def uploadMediaFile options
		if validateParamsPresence?(options, ['url','phoneNumber'])
			
			post_body = {
							'username' => @username,
							'url'      => options['url'],
							'phoneNumber' => options['phoneNumber']
						}
			url = getVoiceHost() + "/mediaUpload"
			# 
			response = sendNormalRequest(url, post_body)
		end
		if(@response_code == HTTP_OK || @response_code == HTTP_CREATED)
			return UploadMediaResponse.new response
		end
		# 
		raise AfricasTalkingException, response
	end


	private
		def getVoiceHost()
			if(@username == "sandbox")
				return "https://voice.sandbox.africastalking.com"
			else
				return "https://voice.africastalking.com"
			end
		end

end


class CallResponse
	attr_reader :errorMessage, :entries

	def initialize(entries_, errorMessage_)
		@errorMessage      = errorMessage_
		@entries = entries_
	end
end

class CallEntries
	attr_reader :status, :phoneNumber

	def initialize(status_, number_)
		@status      = status_
		@phoneNumber = number_
	end
end

class QueuedCalls
	attr_reader :numCalls, :phoneNumber, :queueName
	
	def initialize(number_, numCalls_, queueName_)
		@phoneNumber = number_
		@numCalls    = numCalls_
		@queueName   = queueName_
	end
end

class QueuedCallsResponse
	attr_reader :status, :errorMessage, :entries

	def initialize(status_, errorMessage_, entries_)
		@status = status_
		@errorMessage    = errorMessage_
		@entries   = entries_
	end
end

class UploadMediaResponse
	attr_reader :status
	def initialize status
		@status = status
	end
end

