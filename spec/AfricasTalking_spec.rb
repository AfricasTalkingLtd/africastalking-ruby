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
		options = {
			'phoneNumber' => "+25472232#{rand(1000...9999)}"
		}
		expect(token.createCheckoutToken options).to have_attributes(:description => "Success", :token => a_value)
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
		options = {
			'message' => 'sample message',
			'to' => "+25472232#{rand(1000...9999)}, +25476334#{rand(1000...9999)}",
			'from' => nil,
			'enqueue' => nil,
			'bulkSMSMode' => nil,
			'retryDurationInHours' => nil
		}
		expect(sms.sendMessage options).to inspect_BulkMessageResponse
	end

	it "should send premium message" do
		sms = @gateway.sms
		options = {
			'message' => 'sample message',
			'keyword' => 'gemtests',
			'linkId' => "a0aad2b0-6615-4552-a415-de636cb92c00",
			'to' => ["+25472232#{rand(1000...9999)}, +25476334#{rand(1000...9999)}"],
			'from' => nil,
			'enqueue' => nil,
			'bulkSMSMode' => nil,
			'retryDurationInHours' => nil
		}
		expect(sms.sendPremiumMessage options).to inspect_PremiumMessageResponse
	end

	it "should be able to fetch messages" do
		sms = @gateway.sms
		options = {
			'last_received_id' => nil
		}
		expect(sms.fetchMessages options).to inspect_FetchMessageResponse
		# expect(@gateway.fetch_messages).to inspect_SMSMessages
	end

	# not completed this test. remember to consider empty responses
	it "should be able to fetch subscriptions" do
		# p @gateway.fetch_messages
		sms = @gateway.sms
		options = {
			'shortCode' => '77777',
			'keyword' => 'gemtests',
			'lastReceivedId' => nil
		}
		expect(sms.fetchSubscriptions options).to inspect_FetchSubscriptionResponse
	end	

	# not complete. you need to check what the checkoutToken is
	it "should be able to create subscriptions" do
		# p @gateway.fetch_messages
		sms = @gateway.sms
		options = {
			'shortCode' => '202020',
			'keyword' => 'premium',
			'phoneNumber' => '0723232323',
			'checkoutToken' => 'checkoutToken'
		}
		expect(sms.createSubcriptions options).to have_attributes(:status => a_value, :description => a_value)
	end



	# ///////////////////AIRTIME//////////////////////

	it "should be able to send airtime to a phone number" do 
		airtime = @gateway.airtime
		options = [
			{'phoneNumber' => "+25472232#{rand(1000...9999)}", 'amount' => 'KES 100'},
			{'phoneNumber' => "+25476334#{rand(1000...9999)}", 'amount' => 'KES 100'}
		]
		expect(airtime.sendAirtime options).to inspect_SendAirtimeResult
	end

	# ////////////////////////////////////////////

	# ////////////////////////////VOICE///////////////////////////////////

	# returns a string instead of 
	it "should be able to make call" do
		voice = @gateway.voice
		options = {
			'from' => "+254722123456",
			'to'   => "+25471147#{rand(1000...9999)}, +25473383#{rand(1000...9999)}"
	}
		expect(voice.call options).to inspect_CallResponse
	end

	# can still return empty array of entries. check into it
	it "should be able to fetch queued calls" do
		voice = @gateway.voice
		options = {
			'phoneNumber' => '+254722123456'
		}
		expect(voice.fetchQueuedCalls options).to inspect_QueuedCallsResponse
	end

	it "should be able to upload media files" do
		voice = @gateway.voice
		options = {
			'url' => 'http://onlineMediaUrl.com/file.wav',
			'phoneNumber' => "+254722123456"
		}
		expect(voice.uploadMediaFile options).to have_attributes(:status => a_value)
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
		options = {
			'productName' => 'RUBY_GEM_TEST',
			'phoneNumber' => '0722232323',
			'currencyCode'=> 'KES',
			'amount' => '200',
			'metadata'=> {}
		}
		expect(payments.initiateMobilePaymentCheckout options ).to have_attributes(:status => a_value, :transactionFee => a_value, :transactionId => a_value, :providerChannel => a_value)

	end

	it "initiate mobile B2C payment" do
		payments = @gateway.payments
		options = {
			'productName' => 'RUBY_GEM_TEST',
			'recipients' => [
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
		}
		expect(payments.mobilePaymentB2CRequest options).to inspect_MobileB2CResponse
		
	end

	it "initiate mobile B2B request" do
		payments = @gateway.payments
		options = {
			'productName' => 'RUBY_GEM_TEST',
			'currencyCode' => 'KES',
			'amount' => '100.50',
			'metadata' => {
				'shopId' => "1234",
				'itemId' => "abcde"
			},
			'providerData' => {
				'provider' => 'Athena',
				'destinationChannel' => '121212',
				'destinationAccount' => 'destinationAccount',
				'transferType' => 'BusinessToBusinessTransfer'
			}
		}
		expect(payments.mobilePaymentB2BRequest options).to have_attributes(:status => a_value, :transactionId => a_value, :transactionFee => a_value, :providerChannel => a_value)
		
	end

	it "initiate bank charge checkout" do
		payments = @gateway.payments
		options = {
			'productName' => 'RUBY_GEM_TEST',
			'currencyCode'=> 'KES',
			'amount' => '500.50',
			'narration' => 'This is a test transaction',
			'metadata' => {
				'requestId' => "1234",
				'applicationId' => "abcde"
			},
			'bankAccount' => {
				'accountName' => 'Test Bank Account',
				'accountNumber' => "1234567#{rand(100...999)}",
				'bankCode' => 234001,
				'dateOfBirth' => '2017-11-22'
			}
		}
		expect(payments.initiateBankChargeCheckout options ).to have_attributes(:status => a_value, :description => a_value, :transactionId => a_value)
	end

	it "validate bank account checkout" do
		payments = @gateway.payments
		options = {
			'transactionId' => 'ATPid_SampleTxnId1',
			'otp' => '1234'
		}
		expect(payments.validateBankAccountCheckout options).to have_attributes(:status => a_value, :description => a_value)
	end

	it "initiate bank transfer request" do
		payments = @gateway.payments
		options = {
			'productName' => 'RUBY_GEM_TEST',
			'recipients' => [
				{
					'currencyCode' => 'KES',
					'amount' => "200.00",
					'narration' => 'This is a test transaction e.g. Salary Payment ',
					'metadata' => {
						"description" => "May Salary",
						"departmentId" => "124"
					},
					'bankAccount' => {
						'accountName' => 'Test Bank Account',
						'accountNumber' => "123456#{rand(1000...9999)}",
						'bankCode' => 234001
					}
				},
				{
					'currencyCode' => 'KES',
					'amount' => "5000.00",
					'narration' => 'This is a test transaction 2 e.g. Salary Payment ',
					'metadata' => {
						"description" => "May Salary",
						"departmentId" => "125"
					},
					'bankAccount' => {
						'accountName' => 'Second Test Bank Account',
						'accountNumber' => "098765#{rand(1000...9999)}",
						'bankCode' => 234009
					}
				}
			]
		}
		expect(payments.initiateBankTransferRequest options ).to inspect_BankTransferResponse
	end

	it "initiate card checkout" do
		payments = @gateway.payments
		options = {
			'productName' => 'RUBY_GEM_TEST',
			'currencyCode'=> 'KES',
			'amount' => '1200',
			'narration' => 'test narration',
			'checkoutToken' => nil,
			'metadata' => {},
			'paymentCard' => {
				"number"=> "5105105105105100",
				"cvvNumber"=> 654,
				"expiryMonth"=> 9,
				"expiryYear"=> 2020,
				"countryCode"=> "NG",
				"authToken"=> "12345",
			}
		}
		expect(payments.initiateCardCheckout options ).to have_attributes(:status => a_value, :description => a_value, :transactionId => a_value)
	end

	it "validate card checkout" do
		payments = @gateway.payments
		options = {
			'transactionId' => 'ATPid_39a71bc00951cd1d3ed56d419d0ab3b6',
			'otp' => '1234'
		}
		expect(payments.validateCardCheckout options ).to have_attributes(:status => a_value, :description => a_value, :checkoutToken => a_value)
	end

	it 'initiate wallet transfer request' do 
		payments = @gateway.payments
		options = {
			'productName' => 'RUBY_GEM_TEST',
			'targetProductCode' => 2373,
			'currencyCode' => 'KES',
			'amount' => 2000,
			'metadata' => {
				"description" => "May Rent"
			}
		}
		expect(payments.walletTransferRequest options ).to have_attributes(:status => a_value, :description => a_value, :transactionId => a_value)
	end

	it 'initiate topup stash request' do 
		payments = @gateway.payments
		options = {
			'productName' => 'RUBY_GEM_TEST',
			'currencyCode' => 'KES',
			'amount' => 2000,
			'metadata' => {
				"description" => "moving money"
			}
		}
		expect(payments.topupStashRequest options ).to have_attributes(:status => a_value, :description => a_value, :transactionId => a_value)
	end

	# ///////////////////////////////////////////////////////////////////


end
