RSpec.describe AfricasTalking do

	before(:each) do
	    @gateway=AfricasTalking::Gateway.new('sandbox', 'bed6bd70401f3110e7f8c347b0819efa7012f64f689b3c0fa8dd1f452224861b', 'sandbox')
	end

	it "has a version number" do
		expect(AfricasTalking::VERSION).not_to be nil
	end

	# ///////////////////TOKEN////////////////////////
	it "should be able to generate checkout token" do
		# p @gateway
		token = @gateway.token
		expect(token.createCheckoutToken "+25472232#{rand(1000...9999)}").to have_attributes(:description => "Success", :token => a_value)
	end

	it "should be able to generate checkout token" do
		# p @gateway
		token = @gateway.token
		expect(token.createAuthToken).to have_attributes(:lifetimeInSeconds => a_value, :token => a_value)
	end

	# //////////////////////////////////////////////


	# ///////////////////SMS////////////////////////

	it "should be able to send bulk message" do
		# p @gateway
		sms = @gateway.sms
		expect(sms.sendMessage 'sample message', "+25472232#{rand(1000...9999)}, +25476334#{rand(1000...9999)}").to inspect_BulkMessageResponse
	end

	it "should send premium message" do
		sms = @gateway.sms
		expect(sms.sendPremiumMessage 'sample message', 'gemtests', 'a0aad2b0-6615-4552-a415-de636cb92c00', ["+25472232#{rand(1000...9999)}, +25476334#{rand(1000...9999)}"]).to inspect_PremiumMessageResponse
	end

	it "should be able to fetch messages" do
		sms = @gateway.sms
		expect(sms.fetchMessages).to inspect_FetchMessageResponse
		# expect(@gateway.fetch_messages).to inspect_SMSMessages
	end

	# not completed this test. remember to consider empty responses
	it "should be able to fetch subscriptions" do
		# p @gateway.fetch_messages
		sms = @gateway.sms
		expect(sms.fetchSubscriptions '77777', 'gemtests', '').to inspect_FetchSubscriptionResponse
	end	

	# not complete. you need to check what the checkoutToken is
	it "should be able to create subscriptions" do
		# p @gateway.fetch_messages
		sms = @gateway.sms
		expect(sms.createSubcriptions '202020', 'premium', '0723232323', 'checkoutToken').to have_attributes(:status => a_value, :description => a_value)
	end



	# ///////////////////AIRTIME//////////////////////

	it "should be able to send airtime to a phone number" do 
		airtime = @gateway.airtime
		recipients = [
			{'phoneNumber' => "+25472232#{rand(1000...9999)}", 'amount' => 'KES 100'},
			{'phoneNumber' => "+25476334#{rand(1000...9999)}", 'amount' => 'KES 100'}
		]
		expect(airtime.sendAirtime recipients).to inspect_SendAirtimeResult
	end

	# ////////////////////////////////////////////

	# ////////////////////////////VOICE///////////////////////////////////

	# returns a string instead of 
	it "should be able to make call" do
		voice = @gateway.voice
		from = "+254722123456"
		to   = "+25471147#{rand(1000...9999)}, +25473383#{rand(1000...9999)}"

		expect(voice.call to, from).to inspect_CallResponse
	end

	# can still return empty array of entries. check into it
	it "should be able to fetch queued calls" do
		voice = @gateway.voice
		phoneNumber = '+254722123456'
		expect(voice.fetchQueuedCalls phoneNumber).to inspect_QueuedCallsResponse
	end

	it "should be able to upload media files" do
		voice = @gateway.voice
		url = 'http://onlineMediaUrl.com/file.wav'
		# phoneNumber = "%2B254724434562"
		phoneNumber = "+254722123456"
		# phoneNumber = "0712345678 "
		expect(voice.uploadMediaFile url, phoneNumber).to have_attributes(:status => a_value)
	end

	# ///////////////////////////////////////////////////////////////////

	# /////////////////////////ACCOUNT////////////////////////////
	it "should be able to fetch account details" do
		account = @gateway.account
		expect(account.fetchUserData).to have_attributes(:balance => a_value)
	end
	# ////////////////////////////////////////////////////////////



	# /////////////////////////PAYMENTS////////////////////////////

	it "initiate Mobile Payment Checkout" do
		payments = @gateway.payments
		expect(payments.initiateMobilePaymentCheckout 'RUBY_GEM_TEST', '0722232323',  'KES', '200' ).to have_attributes(:status => a_value, :transactionFee => a_value, :transactionId => a_value, :providerChannel => a_value)

	end

	it "initiate mobile B2C payment" do
		payments = @gateway.payments
		recipients = [
			{
				"name" => "Payments Test",
			    "phoneNumber"=> '+254722222222',
			    "currencyCode"=> "KES",
			    "amount"=> '100',
			    "reason"=> "SalaryPayment",
			    "metadata" => {
			       "description" => "test employee",
			       "employeeId" => "123"
			    }
			},
			{
				"name" => "Payments Test",
			    "phoneNumber"=> '+254722333322',
			    "currencyCode"=> "KES",
			    "amount"=> '2000',
			    "reason"=> "SalaryPayment",
			    "metadata" => {
			       "description" => "test employee",
			       "employeeId" => "123"
			    }
			}
		]
		expect(payments.mobilePaymentB2CRequest 'RUBY_GEM_TEST', recipients).to inspect_MobileB2CResponse
		
	end

	it "initiate mobile B2B request" do
		payments = @gateway.payments
		providerData = {
	        'provider' => 'Athena',
	        'destinationChannel' => '121212',
	        'destinationAccount' => 'destinationAccount',
	        'transferType' => 'BusinessToBusinessTransfer'
       	}
       	metadata = {
            'shopId' => "1234",
            'itemId' => "abcde"
        }
		expect(payments.mobilePaymentB2BRequest 'RUBY_GEM_TEST', providerData, 'KES', '100.50', metadata = {} ).to have_attributes(:status => a_value, :transactionId => a_value, :transactionFee => a_value, :providerChannel => a_value)
		
	end

	it "initiate bank charge checkout" do
		payments = @gateway.payments
		bankAccount = {
	        'accountName' => 'Test Bank Account',
	        'accountNumber' => "1234567#{rand(100...999)}",
	        'bankCode' => 234001,
	        'dateOfBirth' => '2017-11-22'
       	}
       	metadata = {
            'requestId' => "1234",
            'applicationId' => "abcde"
        }
        narration = 'This is a test transaction'

		expect(payments.initiateBankChargeCheckout 'RUBY_GEM_TEST', bankAccount, 'KES', '500.50', narration, metadata = {} ).to have_attributes(:status => a_value, :description => a_value, :transactionId => a_value)
	end

	it "validate bank account checkout" do
		payments = @gateway.payments
		expect(payments.validateBankAccountCheckout 'ATPid_SampleTxnId1', '1234').to have_attributes(:status => a_value, :description => a_value)
	end

	it "initiate bank transfer request" do
		payments = @gateway.payments
		recipient1 = {
			'bankAccount' => {
				'accountName' => 'Test Bank Account',
		        'accountNumber' => "123456#{rand(1000...9999)}",
		        'bankCode' => 234001
			},
	        'currencyCode' => 'KES',
	        'amount' => "200.00",
            'narration' => 'This is a test transaction e.g. Salary Payment ',
            'metadata' => {
	       		"description" => "May Salary",
	       		"departmentId" => "124"
	       	}
       	}
       	recipient2 = {
       		'bankAccount' => {
				'accountName' => 'Second Test Bank Account',
		        'accountNumber' => "098765#{rand(1000...9999)}",
		        'bankCode' => 234009
			},
	        'currencyCode' => 'KES',
	        'amount' => "5000.00",
            'narration' => 'This is a test transaction 2 e.g. Salary Payment ',
            'metadata' => {
	       		"description" => "May Salary",
	       		"departmentId" => "125"
	        }
       	}
       	recipients = [ recipient1, recipient2 ]
		expect(payments.initiateBankTransferRequest 'RUBY_GEM_TEST', recipients ).to inspect_BankTransferResponse
	end

	it "initiate card checkout" do
		payments = @gateway.payments
		paymentCard = {
	        "number"=> "5105105105105100",
	        "cvvNumber"=> 654,
	        "expiryMonth"=> 9,
	        "expiryYear"=> 2020,
	        "countryCode"=> "NG",
	        "authToken"=> "12345",
	    }
		expect(payments.initiateCardCheckout 'RUBY_GEM_TEST', 'KES', '1200', 'test narration', nil, paymentCard, nil ).to have_attributes(:status => a_value, :description => a_value, :transactionId => a_value)
	end

	it "validate card checkout" do
		payments = @gateway.payments
		expect(payments.validateCardCheckout 'ATPid_39a71bc00951cd1d3ed56d419d0ab3b6', '1234' ).to have_attributes(:status => a_value, :description => a_value, :checkoutToken => a_value)
	end

	it 'initiate wallet transfer request' do 
		payments = @gateway.payments
		metadata = {
	        "description" => "May Rent"
	    }
		expect(payments.walletTransferRequest 'RUBY_GEM_TEST', 2373, 'KES', 2000, metadata ).to have_attributes(:status => a_value, :description => a_value, :transactionId => a_value)
	end

	it 'initiate topup stash request' do 
		payments = @gateway.payments
		metadata = {
	        "description" => "moving money"
	    }
		expect(payments.topupStashRequest 'RUBY_GEM_TEST', 'KES', 2000, metadata ).to have_attributes(:status => a_value, :description => a_value, :transactionId => a_value)
	end

	# ///////////////////////////////////////////////////////////////////


end
