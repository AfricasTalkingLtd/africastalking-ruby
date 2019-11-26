# frozen_string_literal: true

# Application class
class Application
  include AfricasTalking
  HTTP_CREATED     = 201
  HTTP_OK          = 200

  # Set debug flag to to true to view response body
  def initialize(username, apikey)
    @username    = username
    @apikey      = apikey
  end

  def fetchApplicationData
    url      = getUserDataUrl + '?username=' + @username + ''
    response = sendNormalRequest(url)
    if @response_code == HTTP_OK
      result = JSON.parse(response, quirky_mode: true)
      return ApplicationDataResponse.new result['balance']
    else
      raise AfricasTalkingException, response
    end
  end

  private

  def getUserDataUrl
    getApiHost + '/version1/user'
  end

  def getApiHost
    if @username == 'sandbox'
      'https://api.sandbox.africastalking.com'
    else
      'https://api.africastalking.com'
    end
  end
end
# ApplicationDataResponse class
class ApplicationDataResponse
  attr_reader :balance
  def initialize(balance_)
    @balance = balance_
  end
end
