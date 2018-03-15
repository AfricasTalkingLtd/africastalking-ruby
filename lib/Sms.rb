require "AfricasTalking/version"
require 'httparty'
require 'httmultiparty'
require 'json'
require "AfricasTalking"
require 'pry'

module AfricasTalking
	
	# /////////////////////////
	class Sms < Gateway
		attr_accessor :message, :username, :apikey, :environment
		def initialize username, apikey, environment = nil
			@username    = username
			@apikey      = apikey
			@environment  = environment
		end

		# def initialize
		# 	super
		# end
	
		
		def sendMessage message, recipients, senderId, enqueue = nil 
			# binding.pry
			post_body = {

				'username'    => @username, 
				'message'     => message, 
				'to'          => recipients
			}
			

			response = executePost(getSmsUrl(), post_body)
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

		# def sendPremiumMessage message, keyword, linkId, recipients, senderId = nil , retryDurationInHours = nil
		# 	post_body = {
		# 					'username'    => @username, 
		# 					'message'     => message, 
		# 					'to'          => recipients
		# 				}
		# 	response = executePost(getSmsUrl(), post_body)
		# end

		def fetchMessages last_received_id = nil
			url = getSmsUrl() + "?username=#{@username}&lastReceivedId=#{last_received_id}"
			response = executePost(url)
			if @response_code == HTTP_OK
				messages = JSON.parse(response, :quirky_mode => true)["SMSMessageData"]["Messages"].collect { |msg|
					SMSMessages.new msg["id"], msg["text"], msg["from"] , msg["to"], msg["linkId"], msg["date"]
				}
				# binding.pry
				return messages
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
				subscriptions = JSON.parse(response)['responses'].collect{ |subscriber|
					PremiumSubscriptionNumbers.new subscriber['phoneNumber'], subscriber['id']
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
				return JSON.parse(response, :quirky_mode => true)
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
		attr_accessor :phoneNumber, :id

		def initialize(number_, id_)
			@phoneNumber = number_
			@id     = id_
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
