# frozen_string_literal: true

class Sms
  include AfricasTalking

  HTTP_CREATED     = 201
  HTTP_OK          = 200

  # Set debug flag to to true to view response body

  def initialize(username, apikey)
    @username    = username
    @apikey      = apikey
  end

  # def initialize
  #   super
  # end

  def send(options)
    post_body = {

      'username' => @username,
      'message' => options['message'],
      'to' => options['to']
    }
    post_body['from'] = options['from'] unless options['from'].nil?
    post_body['enqueue'] = 1 if options['enqueue'] === true
    unless options['bulkSMSMode'].nil?
      post_body['bulkSMSMode'] = options['bulkSMSMode']
    end
    unless options['retryDurationInHours'].nil?
      post_body['retryDurationInHours'] = options['retryDurationInHours']
    end
    if validateParamsPresence?(options, %w[message to])
      response = sendNormalRequest(getSmsUrl, post_body)
   end
    if @response_code == HTTP_CREATED
      messageData = JSON.parse(response, quirks_mode: true)['SMSMessageData']
      recipients = messageData['Recipients']

      unless recipients.empty?
        reports = recipients.collect do |entry|
          StatusReport.new entry['number'], entry['status'], entry['cost'], entry['messageId']
        end
        return reports
      end

      raise AfricasTalkingException, messageData['Message']

    else
      raise AfricasTalkingException, response
    end
  end

  def sendPremium(options)
    post_body = {
      'username' => @username,
      'message' => options['message'],
      'to' => options['to'],
      'keyword' => options['keyword'],
      'linkId' => options['linkId']
    }
    unless options['retryDurationInHours'].nil?
      post_body['retryDurationInHours'] = options['retryDurationInHours']
    end
    unless options['bulkSMSMode'].nil?
      post_body['bulkSMSMode'] = options['bulkSMSMode']
    end
    post_body['enqueue'] = options['enqueue'] unless options['enqueue'].nil?
    post_body['from'] = options['from'] unless options['from'].nil?
    if validateParamsPresence?(options, %w[message to keyword linkId])
      response = sendNormalRequest(getSmsUrl, post_body)
    end

    if @response_code == HTTP_CREATED
      messageData = JSON.parse(response, quirks_mode: true)['SMSMessageData']
      recipients = messageData['Recipients']

      unless recipients.empty?
        reports = recipients.collect do |entry|
          StatusReport.new entry['number'], entry['status'], entry['cost'], entry['messageId']
        end
        return SendPremiumMessagesResponse.new reports, messageData['Message']
      end

      raise AfricasTalkingException, messageData['Message']

    else
      raise AfricasTalkingException, response
    end
  end

  def fetchMessages(options)
    url = getSmsUrl + "?username=#{@username}&lastReceivedId=#{options['last_received_id']}"
    response = sendNormalRequest(url)
    if @response_code == HTTP_OK
      messages = JSON.parse(response, quirky_mode: true)['SMSMessageData']['Messages'].collect do |msg|
        SMSMessages.new msg['id'], msg['text'], msg['from'], msg['to'], msg['linkId'], msg['date']
      end
      # messages

      return FetchMessagesResponse.new messages

    else
      raise AfricasTalkingException, response
    end
  end

  def fetchSubscriptions(options)
    if validateParamsPresence?(options, %w[shortCode keyword])
      url = getSmsSubscriptionUrl + "?username=#{@username}&shortCode=#{options['shortCode']}&keyword=#{options['keyword']}&lastReceivedId=#{options['lastReceivedId']}"
      response = sendNormalRequest(url)
    end
    if @response_code == HTTP_OK
      subscriptions = JSON.parse(response)['responses'].collect do |subscriber|
        PremiumSubscriptionNumbers.new subscriber['phoneNumber'], subscriber['id'], subscriber['date']
      end
      return subscriptions
    else
      raise AfricasTalkingException, response
    end
  end

  def createSubcription(options)
    post_body = {
      'username' => @username,
      'phoneNumber' => options['phoneNumber'],
      'shortCode' => options['shortCode'],
      'keyword' => options['keyword']
    }
    unless options['checkoutToken'].nil?
      post_body['checkoutToken'] = options['checkoutToken']
    end
    url = getSmsSubscriptionUrl + '/create'
    if validateParamsPresence?(options, %w[shortCode keyword phoneNumber])
      response = sendNormalRequest(url, post_body)
    end
    if @response_code == HTTP_CREATED
      r = JSON.parse(response, quirky_mode: true)
      return CreateSubscriptionResponse.new r['status'], r['description']
    else
      raise AfricasTalkingException, response
    end
  end

  def deleteSubcription(options)
    post_body = {
      'username' => @username,
      'phoneNumber' => options['phoneNumber'],
      'shortCode' => options['shortCode'],
      'keyword' => options['keyword']
    }
    unless options['checkoutToken'].nil?
      post_body['checkoutToken'] = options['checkoutToken']
    end
    url = getSmsSubscriptionUrl + '/delete'
    if validateParamsPresence?(options, %w[shortCode keyword phoneNumber])
      response = sendNormalRequest(url, post_body)
    end
    if @response_code == HTTP_CREATED
      r = JSON.parse(response, quirky_mode: true)
      return DeleteSubscriptionResponse.new r['status'], r['description']
    else
      raise AfricasTalkingException, response
    end
  end

  private

  def getSmsUrl
    getApiHost + '/version1/messaging'
  end

  def getSmsSubscriptionUrl
    getApiHost + '/version1/subscription'
  end

  def getApiHost
    if @username == 'sandbox'
      'https://api.sandbox.africastalking.com'
    else
      'https://api.africastalking.com'
    end
  end
end
# ////////////////////////

class StatusReport
  attr_reader :number, :status, :cost, :messageId

  def initialize(number_, status_, cost_, messageId_)
    @number = number_
    @status = status_
    @cost   = cost_
    @messageId = messageId_
  end
end

class PremiumSubscriptionNumbers
  attr_reader :phoneNumber, :id, :date

  def initialize(number_, id_, date_)
    @phoneNumber = number_
    @id = id_
    @date = date_
  end
end

class FetchMessagesResponse
  attr_reader :responses, :status
  def initialize(responses_, status_ = nil)
    @responses = responses_
    @status = status_
  end
end

class CreateSubscriptionResponse
  attr_reader :status, :description
  def initialize(status_, description_)
    @description = description_
    @status = status_
  end
end

class DeleteSubscriptionResponse
  attr_reader :status, :description
  def initialize(status_, description_)
    @description = description_
    @status = status_
  end
end

class SendPremiumMessagesResponse
  attr_reader :recipients, :overview
  def initialize(recipients_, overview_)
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
