class Sms
	include AfricasTalking

	HTTP_CREATED     = 201
	HTTP_OK          = 200

	#Set debug flag to to true to view response body

	def initialize username, apikey
		@username    = username
		@apikey      = apikey
	end

	# def initialize
	# 	super
	# end

	
	def sendMessage options
		# 
		post_body = {

			'username'    => @username, 
			'message'     => options['message'], 
			'to'          => options['to']
		}	
		if options['from'] != nil
			post_body['from'] = options['from']
		end
		if options['enqueue'] != nil
			post_body['enqueue'] = options['enqueue']
		end
		if options['bulkSMSMode'] != nil
			post_body['bulkSMSMode'] = options['bulkSMSMode']
		end
		if options['retryDurationInHours'] != nil
			post_body['retryDurationInHours'] = options['retryDurationInHours']
		end
		# 
		if validateParamsPresence?(options, ['message', 'to'])
			response = sendNormalRequest(getSmsUrl(), post_body)
		end
		if @response_code == HTTP_CREATED
			messageData = JSON.parse(response,:quirks_mode=>true)["SMSMessageData"]
			recipients = messageData["Recipients"]
			
			if recipients.length > 0
				reports = recipients.collect { |entry|
					StatusReport.new entry["number"], entry["status"], entry["cost"], entry["messageId"]
				}
				# 
				return reports
			end
			
			raise AfricasTalkingGatewayException, messageData["Message"]
			
		else
			raise AfricasTalkingGatewayException, response
		end
	end

	def sendPremiumMessage options
		post_body = {
			'username'    => @username, 
			'message'     => options['message'], 
			'to'          => options['to'],
			'keyword'     => options['keyword'],
			'linkId'      => options['linkId'],
		}
		if options['retryDurationInHours'] != nil
			post_body['retryDurationInHours'] = options['retryDurationInHours']
		end
		if options['bulkSMSMode'] != nil
			post_body['bulkSMSMode'] = options['bulkSMSMode']
		end
		if options['enqueue'] != nil
			post_body['enqueue'] = options['enqueue']
		end
		if options['from'] != nil
			post_body['from'] = options['from']
		end
		# 
		if validateParamsPresence?(options, ['message', 'to', 'keyword', 'linkId'])
			response = sendNormalRequest(getSmsUrl(), post_body)
		end
		
		# 
		if @response_code == HTTP_CREATED
			messageData = JSON.parse(response,:quirks_mode=>true)["SMSMessageData"]
			recipients = messageData["Recipients"]
			
			if recipients.length > 0
				reports = recipients.collect { |entry|
					StatusReport.new entry["number"], entry["status"], entry["cost"], entry["messageId"]
				}
				return SendPremiumMessagesResponse.new reports, messageData["Message"]
			end
			
			raise AfricasTalkingGatewayException, messageData["Message"]
			
		else
			raise AfricasTalkingGatewayException, response
		end

		# 
	end

	def fetchMessages options
		url = getSmsUrl() + "?username=#{@username}&lastReceivedId=#{options['last_received_id']}"
		response = sendNormalRequest(url)
		if @response_code == HTTP_OK
			messages = JSON.parse(response, :quirky_mode => true)["SMSMessageData"]["Messages"].collect { |msg|
				SMSMessages.new msg["id"], msg["text"], msg["from"] , msg["to"], msg["linkId"], msg["date"]
			}
				# messages

			return FetchMessagesResponse.new messages

		else
			raise AfricasTalkingGatewayException, response
		end
	end

	def fetchSubscriptions options
		if validateParamsPresence?(options, ['shortCode', 'keyword'])
			url = getSmsSubscriptionUrl() + "?username=#{@username}&shortCode=#{options['shortCode']}&keyword=#{options['keyword']}&lastReceivedId=#{options['lastReceivedId']}"
			response = sendNormalRequest(url)
		end
		if(@response_code == HTTP_OK)
			# 
			subscriptions = JSON.parse(response)['responses'].collect{ |subscriber|
				PremiumSubscriptionNumbers.new subscriber['phoneNumber'], subscriber['id'], subscriber['date']
			}
			# 
			return subscriptions
		else
			raise AfricasTalkingGatewayException, response
		end
	end

	def createSubcriptions options
		post_body = {
						'username'    => @username,
						'phoneNumber' => options['phoneNumber'],
						'shortCode'   => options['shortCode'],
						'keyword'     => options['keyword']
					}
		if options['checkoutToken'] != nil
			post_body['checkoutToken'] = options['checkoutToken']
		end
		url = getSmsSubscriptionUrl() + "/create"
		if validateParamsPresence?(options, ['shortCode', 'keyword', 'phoneNumber'])
			response = sendNormalRequest(url, post_body)
		end
		if(@response_code == HTTP_CREATED)
			r = JSON.parse(response, :quirky_mode => true)
			return CreateSubscriptionResponse.new r['status'], r['description'] 
		else
			raise AfricasTalkingGatewayException, response
		end
	end

	private

		def getSmsUrl()
			return  getApiHost() + "/version1/messaging"
		end

		def getSmsSubscriptionUrl()
			return getApiHost() + "/version1/subscription"
		end

		def getApiHost()
			if(@username == "sandbox")
				return "https://api.sandbox.africastalking.com"
			else
				return "https://api.africastalking.com"
			end
		end

		def sendNormalRequest(url_, data_ = nil)
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
end
# ////////////////////////

class StatusReport
	attr_reader :number, :status, :cost, :messageId

	def initialize(number_, status_, cost_,messageId_)
		@number = number_
		@status = status_
		@cost   = cost_
		@messageId = messageId_
	end
end

class PremiumSubscriptionNumbers
	attr_reader :phoneNumber, :id, :date

	def initialize number_, id_, date_
		@phoneNumber = number_
		@id     = id_
		@date = date_
	end
end


class FetchMessagesResponse
	attr_reader :responses, :status 
	def initialize responses_, status_= nil
		@responses = responses_
		@status = status_
	end
end

class CreateSubscriptionResponse
	attr_reader :status, :description
	def initialize status_, description_
		@description = description_
		@status = status_
	end
end


class SendPremiumMessagesResponse
	attr_reader :recipients, :overview 
	def initialize recipients_, overview_
		@recipients = recipients_
		@overview = overview_
	end
end

class SMSMessages
	attr_reader :id, :text, :from, :to, :linkId, :date

	def initialize(id_, text_, from_, to_, linkId_, date_)
		@id     = id_
		@text   = text_
		@from   = from_
		@to     = to_
		@linkId = linkId_
		@date   = date_
	end
end

