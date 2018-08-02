RSpec.describe AfricasTalking do
  before(:each) do
    username = ENV['AT_UNAME']
    api_key = ENV['AT_API']
    @AT = AfricasTalking::Initialize.new username, api_key
  end

  it 'has a version number' do
    expect(AfricasTalking::VERSION).not_to be nil
  end

  describe 'generates token' do
    it 'checkout token' do
      token = @AT.token
      options = { phoneNumber: "+25476334#{rand(1000...9999)}" }
      expect(token.createCheckoutToken(options)).to have_attributes(description: 'Success', token: a_value)
    end

    it 'auth token' do
      token = @AT.token
      expect(token.generateAuthToken).to have_attributes(lifetimeInSeconds: a_value, token: a_value)
    end
  end

  describe 'SMS module' do
    context 'bulk sms' do
      before :each do
        @sms = @AT.sms
        @options = {
          'message' => 'sample message',
          'to' => "+25472232#{rand(1000...9999)}, +25476334#{rand(1000...9999)}",
        }
      end
      it 'sends sms given all correct information' do
        expect { @sms.send @options }.not_to raise_error
        expect(@sms.send(@options)).not_to be_empty
      end
      it 'raises africastalking exception with empty receipient list' do
        @options['to'] = ''
        phone_exception = 'requirement failed: Please provide the phone numbers to send to'
        expect { @sms.send(@options) }
          .to raise_exception(AfricasTalking::AfricasTalkingException, phone_exception)
      end
      it 'raises africastalking exception with no message body' do
        @options['message'] = ''
        empty_message_error = 'requirement failed: The message to send should not be empty'
        expect { @sms.send(@options) }
          .to raise_exception(AfricasTalking::AfricasTalkingException, empty_message_error)
      end
    end

    it 'sends premium messages' do
      sms = @AT.sms
      options = {
        'message' => 'sample message',
        'keyword' => 'gemtests',
        'linkId' => 'a0aad2b0-6615-4552-a415-de636cb92c00',
        'to' => ["+5472232#{rand(1000...9999)}, +5476334#{rand(1000...9999)}"],
      }
      p (sms.sendPremium options).overview
      expect(sms.sendPremium(options)).to inspect_PremiumMessageResponse
    end

    it 'can fetch messages' do
      sms = @AT.sms
      options = {
        'last_received_id' => nil
      }
      expect(sms.fetchMessages(options)).to inspect_FetchMessageResponse
      # expect(@AT.fetch_messages).to inspect_SMSMessages
    end

    # not completed this test. remember to consider empty responses
    it 'should be able to fetch subscriptions' do
      sms = @AT.sms
      options = {
        'shortCode' => '77777',
        'keyword' => 'gemtests',
        'lastReceivedId' => nil
      }
      expect(sms.fetchSubscriptions(options)).to inspect_FetchSubscriptionResponse
    end

    # not complete. you need to check what the checkoutToken is
    it 'should be able to create subscriptions' do
      sms = @AT.sms
      options = {
        'shortCode' => '202020',
        'keyword' => 'premium',
        'phoneNumber' => '0723232323',
        'checkoutToken' => 'checkoutToken'
      }
      expect(sms.createSubcription(options)).to have_attributes(status: a_value, description: a_value)
    end
  end
  # ///////////////////AIRTIME//////////////////////

  it 'should be able to send airtime to a phone number' do
    airtime = @AT.airtime
    options = [
      { 'phoneNumber' => "+25472232#{rand(1000...9999)}", 'amount' => 'KES 100' },
      { 'phoneNumber' => "+25476334#{rand(1000...9999)}", 'amount' => 'KES 100' }
    ]
    expect(airtime.send(options)).to inspect_SendAirtimeResult
  end

  # ////////////////////////////////////////////

  # ////////////////////////////VOICE///////////////////////////////////

  # returns a string instead of
  it 'should be able to make call' do
    voice = @AT.voice
    options = {
      'from' => '+254722123456',
      'to' => "+25471147#{rand(1000...9999)}, +25473383#{rand(1000...9999)}"
    }
    expect(voice.call(options)).to inspect_CallResponse
  end

  # can still return empty array of entries. check into it
  it 'should be able to fetch queued calls' do
    voice = @AT.voice
    options = {
      'phoneNumber' => '+254722123456'
    }
    expect(voice.fetchQueuedCalls(options)).to inspect_QueuedCallsResponse
  end

  it 'should be able to upload media files' do
    voice = @AT.voice
    options = {
      'url' => 'http://onlineMediaUrl.com/file.wav',
      'phoneNumber' => '+254722123456'
    }
    expect(voice.uploadMediaFile(options)).to have_attributes(status: a_value)
  end

  # ///////////////////////////////////////////////////////////////////

  # /////////////////////////ACCOUNT////////////////////////////
  it 'should be able to fetch application details' do
    account = @AT.application
    expect(account.fetchApplicationData).to have_attributes(balance: a_value)
  end
  # ////////////////////////////////////////////////////////////

  # /////////////////////////PAYMENTS////////////////////////////

  it 'initiate Mobile Payment Checkout' do
    payments = @AT.payments
    options = {
      'productName' => 'RUBY_GEM_TEST',
      'phoneNumber' => '0722232323',
      'currencyCode' => 'KES',
      'amount' => '200',
      'metadata' => {}
    }
    expect(payments.mobileCheckout(options)).to have_attributes(status: a_value, transactionFee: a_value, transactionId: a_value, providerChannel: a_value)
  end

  it 'initiate mobile B2C payment' do
    payments = @AT.payments
    options = {
      'productName' => 'RUBY_GEM_TEST',
      'recipients' => [
        {
          'name' => 'Payments Test',
          'phoneNumber' => '+254722222222',
          'currencyCode' => 'KES',
          'amount' => '100',
          'reason' => 'SalaryPayment',
          'metadata' => {
            'description' => 'test employee',
            'employeeId' => '123'
          }
        },
        {
          'name' => 'Payments Test',
          'phoneNumber' => '+254722333322',
          'currencyCode' => 'KES',
          'amount' => '2000',
          'reason' => 'SalaryPayment',
          'metadata' => {
            'description' => 'test employee',
            'employeeId' => '123'
          }
        }
      ]
    }
    expect(payments.mobileB2C(options)).to inspect_MobileB2CResponse
  end

  it 'initiate mobile B2B request' do
    payments = @AT.payments
    options = {
      'productName' => 'RUBY_GEM_TEST',
      'currencyCode' => 'KES',
      'amount' => '100.50',
      'metadata' => {
        'shopId' => '1234',
        'itemId' => 'abcde'
      },
      'providerData' => {
        'provider' => 'Athena',
        'destinationChannel' => '121212',
        'destinationAccount' => 'destinationAccount',
        'transferType' => 'BusinessToBusinessTransfer'
      }
    }
    expect(payments.mobileB2B(options)).to have_attributes(status: a_value, transactionId: a_value, transactionFee: a_value, providerChannel: a_value)
  end

  it 'initiate bank charge checkout' do
    payments = @AT.payments
    options = {
      'productName' => 'RUBY_GEM_TEST',
      'currencyCode' => 'KES',
      'amount' => '500.50',
      'narration' => 'This is a test transaction',
      'metadata' => {
        'requestId' => '1234',
        'applicationId' => 'abcde'
      },
      'bankAccount' => {
        'accountName' => 'Test Bank Account',
        'accountNumber' => "1234567#{rand(100...999)}",
        'bankCode' => 234_001,
        'dateOfBirth' => '2017-11-22'
      }
    }
    expect(payments.bankCheckout(options)).to have_attributes(status: a_value, description: a_value, transactionId: a_value)
  end

  it 'validate bank account checkout' do
    payments = @AT.payments
    options = {
      'transactionId' => 'ATPid_SampleTxnId1',
      'otp' => '1234'
    }
    expect(payments.validateBankCheckout(options)).to have_attributes(status: a_value, description: a_value)
  end

  it 'initiate bank transfer request' do
    payments = @AT.payments
    options = {
      'productName' => 'RUBY_GEM_TEST',
      'recipients' => [
        {
          'currencyCode' => 'KES',
          'amount' => '200.00',
          'narration' => 'This is a test transaction e.g. Salary Payment ',
          'metadata' => {
            'description' => 'May Salary',
            'departmentId' => '124'
          },
          'bankAccount' => {
            'accountName' => 'Test Bank Account',
            'accountNumber' => "123456#{rand(1000...9999)}",
            'bankCode' => 234_001
          }
        },
        {
          'currencyCode' => 'KES',
          'amount' => '5000.00',
          'narration' => 'This is a test transaction 2 e.g. Salary Payment ',
          'metadata' => {
            'description' => 'May Salary',
            'departmentId' => '125'
          },
          'bankAccount' => {
            'accountName' => 'Second Test Bank Account',
            'accountNumber' => "098765#{rand(1000...9999)}",
            'bankCode' => 234_009
          }
        }
      ]
    }
    expect(payments.bankTransfer(options)).to inspect_BankTransferResponse
  end

  it 'initiate card checkout' do
    payments = @AT.payments
    options = {
      'productName' => 'RUBY_GEM_TEST',
      'currencyCode' => 'KES',
      'amount' => '1200',
      'narration' => 'test narration',
      'checkoutToken' => nil,
      'metadata' => {},
      'paymentCard' => {
        'number' => '5105105105105100',
        'cvvNumber' => 654,
        'expiryMonth' => 9,
        'expiryYear' => 2020,
        'countryCode' => 'NG',
        'authToken' => '12345'
      }
    }
    expect(payments.cardCheckout(options)).to have_attributes(status: a_value, description: a_value, transactionId: a_value)
  end

  it 'validate card checkout' do
    payments = @AT.payments
    options = {
      'transactionId' => 'ATPid_39a71bc00951cd1d3ed56d419d0ab3b6',
      'otp' => '1234'
    }
    expect(payments.validateCardCheckout(options)).to have_attributes(status: a_value, description: a_value, checkoutToken: a_value)
  end

  it 'initiate wallet transfer request' do
    payments = @AT.payments
    options = {
      'productName' => 'RUBY_GEM_TEST',
      'targetProductCode' => 2373,
      'currencyCode' => 'KES',
      'amount' => 2000,
      'metadata' => {
        'description' => 'May Rent'
      }
    }
    expect(payments.walletTransferRequest(options)).to have_attributes(status: a_value, description: a_value, transactionId: a_value)
  end

  it 'initiate topup stash request' do
    payments = @AT.payments
    options = {
      'productName' => 'RUBY_GEM_TEST',
      'currencyCode' => 'KES',
      'amount' => 2000,
      'metadata' => {
        'description' => 'moving money'
      }
    }
    expect(payments.topupStashRequest(options)).to have_attributes(status: a_value, description: a_value, transactionId: a_value)
  end

  # ///////////////////////////////////////////////////////////////////
end
