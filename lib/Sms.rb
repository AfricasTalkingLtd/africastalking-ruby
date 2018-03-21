require "AfricasTalking/version"
require 'httparty'
require 'httmultiparty'
require 'json'
require "AfricasTalking"
require 'pry'

module AfricasTalking
	
	# /////////////////////////
	class Sms
		attr_accessor :message, :username, :apikey, :environment

		HTTP_CREATED     = 201
		HTTP_OK          = 200

		#Set debug flag to to true to view response body
		DEBUG            = true

		def initialize username, apikey, environment = nil
			@username    = username
			@apikey      = apikey
			@environment  = environment
		end

		# def initialize
		# 	super
		# end
	
		
		def sendMessage message, recipients, from = nil, enqueue = nil, bulkSMSMode = nil, retryDurationInHours = nil
			# binding.pry
			post_body = {

				'username'    => @username, 
				'message'     => message, 
				'to'          => recipients
			}
			if from != nil
				post_body['from'] = from
			end
			if enqueue != nil
				post_body['enqueue'] = enqueue
			end
			if bulkSMSMode != nil
				post_body['bulkSMSMode'] = bulkSMSMode
			end
			if retryDurationInHours != nil
				post_body['retryDurationInHours'] = retryDurationInHours
			end
			
			response = executePost(getSmsUrl(), post_body)
			# binding.pry
			if @response_code == HTTP_CREATED
				messageData = JSON.parse(response,:quirks_mode=>true)["SMSMessageData"]
				recipients = messageData["Recipients"]
				
				if recipients.length > 0
					reports = recipients.collect { |entry|
						StatusReport.new entry["number"], entry["status"], entry["cost"], entry["messageId"]
					}
					# binding.pry
					return reports
				end
				
				raise AfricasTalkingGatewayException, messageData["Message"]
				
			else
	  			raise AfricasTalkingGatewayException, response
			end
		end

		def sendPremiumMessage message, keyword, linkId, to, from = nil, enqueue = nil, bulkSMSMode = nil, retryDurationInHours = nil
			post_body = {
				'username'    => @username, 
				'message'     => message, 
				'to'          => to,
				'keyword'     => keyword,
				'linkId'      => linkId
			}
			if retryDurationInHours != nil
				post_body['retryDurationInHours'] = retryDurationInHours
			end
			if bulkSMSMode != nil
				post_body['bulkSMSMode'] = bulkSMSMode
			end
			if enqueue != nil
				post_body['enqueue'] = enqueue
			end
			if from != nil
				post_body['from'] = from
			end
			# binding.pry
			response = executePost(getSmsUrl(), post_body)
			
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

			# binding.pry
		end

		def fetchMessages last_received_id = 0
			url = getSmsUrl() + "?username=#{@username}&lastReceivedId=#{last_received_id}"
			response = executePost(url)
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

		def fetchSubscriptions(shortCode, keyword, lastReceivedId)
			if(shortCode.length == 0 || keyword.length == 0)
				raise AfricasTalkingGatewayException, "Please supply the short code and keyword"
			end
			url = getSmsSubscriptionUrl() + "?username=#{@username}&shortCode=#{shortCode}&keyword=#{keyword}&lastReceivedId=#{lastReceivedId}"
			response = executePost(url)
			if(@response_code == HTTP_OK)
				# binding.pry
				subscriptions = JSON.parse(response)['responses'].collect{ |subscriber|
					PremiumSubscriptionNumbers.new subscriber['phoneNumber'], subscriber['id'], subscriber['date']
				}
				# binding.pry

				return subscriptions
			else
				raise AfricasTalkingGatewayException, response
			end
		end

		def createSubcriptions(shortCode, keyword, phoneNumber, checkoutToken)
			if(phoneNumber.length == 0 || shortCode.length == 0 || keyword.length == 0)
				raise AfricasTalkingGatewayException, "Please supply phone number, short code and keyword"
			end
			
			post_body = {
							'username'    => @username,
							'phoneNumber' => phoneNumber,
							'shortCode'   => shortCode,
							'keyword'     => keyword
						}
			url      = getSmsSubscriptionUrl() + "/create"
			response = executePost(url, post_body)
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
	end
	# ////////////////////////

	class StatusReport
		attr_accessor :number, :status, :cost, :messageId

		def initialize(number_, status_, cost_,messageId_)
			@number = number_
			@status = status_
			@cost   = cost_
			@messageId = messageId_
		end
	end

	class PremiumSubscriptionNumbers
		attr_accessor :phoneNumber, :id, :date

		def initialize number_, id_, date_
			@phoneNumber = number_
			@id     = id_
			@date = date_
		end
	end


	class FetchMessagesResponse
		attr_accessor :messages, :status 
		def initialize messages_, status_= nil
			@messages = messages_
			@status = status_
		end
	end

	class CreateSubscriptionResponse
		attr_accessor :status, :description
		def initialize status_, description_
			@description = description_
			@status = status_
		end
	end


	class SendPremiumMessagesResponse
		attr_accessor :reports, :overview 
		def initialize reports_, overview_
			@reports = reports_
			@overview = overview_
		end
	end

	class SMSMessages
		attr_accessor :id, :text, :from, :to, :linkId, :date

		def initialize(id_, text_, from_, to_, linkId_, date_)
			@id     = id_
			@text   = text_
			@from   = from_
			@to     = to_
			@linkId = linkId_
			@date   = date_
		end
	end
end
