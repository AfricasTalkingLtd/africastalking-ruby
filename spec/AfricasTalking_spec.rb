RSpec.describe AfricasTalking do

	before(:each) do
	    @gateway=AfricasTalking::Gateway.new('sandbox', 'bed6bd70401f3110e7f8c347b0819efa7012f64f689b3c0fa8dd1f452224861b', 'sandbox')
	end

	it "has a version number" do
		expect(AfricasTalking::VERSION).not_to be nil
	end

	# ///////////////////SMS////////////////////////

	it "should be able to send bulk message" do
		# p @gateway
		expect(@gateway.send_messages 'sample message', '0722222222, 0733333333', 'sandbox').to inspect_StatusReport(include(status: "Success"))
		
	end

	it "should be able to fetch messages" do
		# p @gateway.fetch_messages
		expect(@gateway.fetch_messages).to inspect_SMSMessages
	end

	# not completed this test. remember to consider empty responses
	it "should be able to fetch subscriptions" do
		# p @gateway.fetch_messages
		expect(@gateway.fetch_subscriptions '77777', 'gemtests', '')
	end	

	# not complete. you need to check what the checkoutToken is
	it "should be able to create subscriptions" do
		# p @gateway.fetch_messages
		expect(@gateway.create_subcriptions '77777', 'gemtests', '0722222222', 'checkoutToken')
	end

	# it "should send premium message" do
		# @gateway=AfricasTalking::Gateway.new('sandbox', 'bed6bd70401f3110e7f8c347b0819efa7012f64f689b3c0fa8dd1f452224861b', 'sandbox')
	# 	p @gateway

	# 	expect(@gateway.send_premium_message('sample message', 'gemtests', 'linkId', "0722222222", '', '')
	# end



	# ///////////////////AIRTIME//////////////////////

	it "should be able to send airtime to a phone number" do 
		recipients = [
			{'phoneNumber' => "+25472232#{rand(1000...9999)}", 'amount' => 'KES 100'},
			{'phoneNumber' => "+25476334#{rand(1000...9999)}", 'amount' => 'KES 100'}
		]
		expect(@gateway.send_airtime recipients).to inspect_AirtimeResult(include(status: "Sent"))
	end

	# ////////////////////////////////////////////

	# ////////////////////////////VOICE///////////////////////////////////

	it "should be able to make call" do
		to = ['+254722222222', '+254733333333']
		from = '+254722123456'

		expect(@gateway.call to, from).to inspect_CallResponse(include(status: "Queued"))
	end


	it "should be able to fetch queued calls" do
		phoneNumber = '+254722123456'

		expect(@gateway.fetch_queued_calls phoneNumber, nil)
	end

	# ///////////////////////////////////////////////////////////////////


	# /////////////////////////PAYMENTS////////////////////////////

	it "initiate initiate Mobile Payment Checkout" do
		expect(@gateway.initiate_mobile_payment_checkout 'RUBY_GEM_TEST', '0722232323',  'KES', '200' )

	end

	it "initiate mobile B2C payment" do
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
		expect(@gateway.mobile_b2c_request  'RUBY_GEM_TEST' ,recipients)
		
	end

	it "initiate mobile B2B request" do
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
		expect(@gateway.mobile_b2b_request 'RUBY_GEM_TEST', providerData, 'KES', '100.50', metadata = {} )
		
	end

	it "initiate bank charge checkout" do
		bankAccount = {
	        'accountName' => 'Test Bank Account',
	        'accountNumber' => '1234567890',
	        'bankCode' => 234001,
	        'dateOfBirth' => '2017-11-22'
       	}
       	metadata = {
            'requestId' => "1234",
            'applicationId' => "abcde"
        }
        narration = 'This is a test transaction'

		expect(@gateway.initiate_bank_charge_checkout 'RUBY_GEM_TEST', bankAccount, 'KES', '500.50', narration, metadata = {} )
	end

	it "validate bank account checkout" do
		expect(@gateway.validate_bank_account_checkout 'ATPid_SampleTxnId1', '1234' )
	end

	it "initiate bank transfer request" do
		recipient1 = {
			'bankAccount' => {
				'accountName' => 'Test Bank Account',
		        'accountNumber' => '1234567890',
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
		        'accountNumber' => '0987654321',
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
		expect(@gateway.initiate_bank_transfer_request 'RUBY_GEM_TEST', recipients )
	end

	it "initiate card checkout" do
		paymentCard = {
	        "number"=> "5105105105105100",
	        "cvvNumber"=> 654,
	        "expiryMonth"=> 9,
	        "expiryYear"=> 2020,
	        "countryCode"=> "NG",
	        "authToken"=> "12345",
	    }
		expect(@gateway.initiate_card_checkout 'RUBY_GEM_TEST', 'KES', '1200', 'test narration', nil, paymentCard, nil )
	end

	it "validate card checkout" do

		expect(@gateway.validate_card_checkout 'ATPid_39a71bc00951cd1d3ed56d419d0ab3b6', '1234' )
	end

	it 'initiate wallet transfer request' do 
		metadata = {
	        "description" => "May Rent"
	    }
		expect(@gateway.wallet_transfer_request 'RUBY_GEM_TEST', 2373, 'KES', 2000, metadata )
	end

	it 'initiate topup stash request' do 
		metadata = {
	        "description" => "moving money"
	    }
		expect(@gateway.topup_stash_request 'RUBY_GEM_TEST', 'KES', 2000, metadata )
	end

	# ///////////////////////////////////////////////////////////////////


end
