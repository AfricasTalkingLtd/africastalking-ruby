require "AfricasTalking/version"
require 'httparty'
require 'httmultiparty'
require 'json'
require 'pry'
require 'Sms'
require 'Payments'
require 'Airtime'
require 'Voice'
require 'Token'
require 'Application'

module AfricasTalking

	class Gateway
		attr_accessor :username, :apikey
		#Set debug flag to to true to view response body
		DEBUG            = true

		def initialize username, apikey
			@username    = username
			@apikey      = apikey 
			@response_code = nil
		end

		def sms
			return AfricasTalking::Sms.new @username, @apikey		
		end

		def payments
			return AfricasTalking::Payments.new @username, @apikey
		end

		def airtime
			return AfricasTalking::Airtime.new @username, @apikey
		end

		def voice
			return AfricasTalking::Voice.new @username, @apikey
		end

		def token
			return AfricasTalking::Token.new @username, @apikey
		end

		def application
			return AfricasTalking::Application.new @username, @apikey
		end



		# /////////////////////////////////////////////////////
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

	class AfricasTalkingGatewayException < Exception
		# error handling appear here
		# def initialize(msg="My default message")
		#     super
		# end

		

	end

end
