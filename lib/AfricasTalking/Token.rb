# frozen_string_literal: true

class Token
  include AfricasTalking
  HTTP_CREATED     = 201
  HTTP_OK          = 200

  # Set debug flag to to true to view response body
  def initialize(username, apikey)
    @username    = username
    @apikey      = apikey
  end

  def generateAuthToken
    post_body = {
      'username' => @username
    }
    url = getApiHost + '/auth-token/generate'
    response = sendJSONRequest(url, post_body)
    if @response_code == HTTP_CREATED
      r = JSON.parse(response, quirky_mode: true)
      return AuthTokenResponse.new r['token'], r['lifetimeInSeconds']
    else
      raise AfricasTalkingException, response
    end
  end

  def createCheckoutToken(options)
    post_body = {
      'phoneNumber' => options['phoneNumber']
    }
    url = getApiHost + '/checkout/token/create'
    response = sendNormalRequest(url, post_body)
    if @response_code == HTTP_CREATED
      r = JSON.parse(response, quirky_mode: true)
      return CheckoutTokenResponse.new r['token'], r['description']
    else
      raise AfricasTalkingException, response
    end
  end

  private

  def getApiHost
    if @username == 'sandbox'
      'https://api.sandbox.africastalking.com'
    else
      'https://api.africastalking.com'
    end
  end
end

class AuthTokenResponse
  attr_accessor :token, :lifetimeInSeconds
  def initialize(token_, lifetimeInSeconds_)
    @token = token_
    @lifetimeInSeconds = lifetimeInSeconds_
  end
end
class CheckoutTokenResponse
  attr_accessor :token, :description
  def initialize(token_, description_)
    @token = token_
    @description = description_
  end
end
