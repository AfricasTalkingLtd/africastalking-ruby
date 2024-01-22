RSpec.describe AfricasTalking do
	before(:each) do
		username = 'username'
		apiKey = 'apiKey'
		@AT=AfricasTalking::Initialize.new username, apiKey

	end

	it "has a version number" do
		expect(AfricasTalking::VERSION).not_to be nil
	end

	# ///////////////////TOKEN////////////////////////
	it "should be able to generate auth token" do
		token = @AT.token
		expect(token.generateAuthToken).to have_attributes(:lifetimeInSeconds => a_value, :token => a_value)
	end

	# //////////////////////////////////////////////


	# ///////////////////SMS////////////////////////

	it "should be able to send bulk message" do
		sms = @AT.sms
		options = {
			'message' => 'sample message',
			'to' => "+25472232#{rand(1000...9999)}, +25476334#{rand(1000...9999)}",
			'from' => nil,
			'enqueue' => nil,
			'bulkSMSMode' => nil,
			'retryDurationInHours' => nil
		}
		expect(sms.send options).to inspect_BulkMessageResponse
	end

	it "should send premium message" do
		sms = @AT.sms
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
		expect(sms.sendPremium options).to inspect_PremiumMessageResponse
	end

	it "should be able to fetch messages" do
		sms = @AT.sms
		options = {
			'last_received_id' => nil
		}
		expect(sms.fetchMessages options).to inspect_FetchMessageResponse
	end

	# not completed this test. remember to consider empty responses
	it "should be able to fetch subscriptions" do
		sms = @AT.sms
		options = {
			'shortCode' => '77777',
			'keyword' => 'gemtests',
			'lastReceivedId' => nil
		}
		expect(sms.fetchSubscriptions options).to inspect_FetchSubscriptionResponse
	end

	it "should be able to create subscriptions" do
		sms = @AT.sms
		options = {
			'shortCode' => '19764',
			'keyword' => 'premium',
			'phoneNumber' => '0723232323'
		}
		expect(sms.createSubcription options).to have_attributes(:status => a_value, :description => a_value)
	end

	it "should be able to delete subscriptions" do
		sms = @AT.sms
		options = {
			'shortCode' => '19764',
			'keyword' => 'premium',
			'phoneNumber' => '0723232323',
		}
		expect(sms.deleteSubcription options).to have_attributes(:status => a_value, :description => a_value)
	end



	# ///////////////////AIRTIME//////////////////////

	it "should be able to send airtime to a phone number" do
		airtime = @AT.airtime

		options =  {
			'recipients' => [{
				'phoneNumber' => "+25472232#{rand(1000...9999)}",
				'currencyCode' => 'KES',
				'amount' => '100',
			},
			{
				'phoneNumber' => "+25476334#{rand(1000...9999)}",
				'currencyCode' => 'KES',
				'amount' => '40',
			}],
			'maxNumRetry' => 3,
		}
		expect(airtime.send options).to inspect_SendAirtimeResult
	end

	# ////////////////////////////////////////////

	# ////////////////////////////VOICE///////////////////////////////////

	# returns a string instead of
	it "should be able to make call" do
		voice = @AT.voice
		options = {
			'from' => "+254722123456",
			# 'to'   => "+25471147#{rand(1000...9999)}, +25473383#{rand(1000...9999)}",
			'to'   => '+254712345678',
			'clientRequestId' => "agent1"
	}
		expect(voice.call options).to inspect_CallResponse
	end

	# can still return empty array of entries. check into it
	it "should be able to fetch queued calls" do
		voice = @AT.voice
		options = {
			'phoneNumber' => '+254722123456'
		}
		expect(voice.fetchQueuedCalls options).to inspect_QueuedCallsResponse
	end

	it "should be able to upload media files" do
		voice = @AT.voice
		options = {
			'url' => 'http://onlineMediaUrl.com/file.wav',
			'phoneNumber' => "+254722123456"
		}
		expect(voice.uploadMediaFile options).to have_attributes(:status => a_value)
	end

	# ///////////////////////////////////////////////////////////////////

	# /////////////////////////ACCOUNT////////////////////////////
	it "should be able to fetch application details" do
		account = @AT.application
		expect(account.fetchApplicationData).to have_attributes(:balance => a_value)
	end
	# ////////////////////////////////////////////////////////////


	# /////////////////////////MOBILEDATA////////////////////////////

	it "Initiate mobile Data Request" do
		mobiledata = @AT.mobiledata
		options = {
		  'idempotencyKey' => '506789',
		  'productName' => 'Mobile Data',
		  'recipients' => [
			{
			  "phoneNumber" => '+254716800998',
			  "quantity" => 50,
			  "unit" => 'MB',
			  "validity" => "Day",
			  "metadata" => {
				"isTesting" => "data bundles",
				"first_name" => "testone",
				"last_name" => "testname"
			  }
			}
		  ]
		}
		response = mobiledata.send(options)
		expect(response).not_to be_nil
		expect(response).to inspect_MobileDataResponse
	end

	it 'Find a mobile data transaction by transactionId' do
		mobiledata = @AT.mobiledata
		options = {
			'transactionId' => 'ATPid_a93f020f2d8e71c1b7bd8c3bf1402f0a',
		}
		expect(mobiledata.findTransaction options).to have_attributes(:status => 'Success')
	end

	it 'Fetch mobile data wallet balance' do
		mobiledata = @AT.mobiledata
		expect(mobiledata.fetchWalletBalance).to have_attributes(:status => 'Success')
	end

	# ///////////////////////////////////////////////////////////////////


end
