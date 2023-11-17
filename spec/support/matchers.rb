# ///////////////////////////////SMS////////////////////////////////////////////////

RSpec::Matchers.define :inspect_BulkMessageResponse do |expected|
  status = []
  match do |actual|
    obj = actual.collect { |item|
      expect(item).to have_attributes(:status => a_value, :cost => a_value, :number => a_value )

    }
    obj.all? {|e| e.eql? true}
    #
    # status.find { |st| st. == expected.expecteds[0][:status] }
    #
  end

  failure_message_when_negated do |actual|
    "something went wrong. bulk sms response test failing"
  end
end


RSpec::Matchers.define :inspect_PremiumMessageResponse do |expected|
  status = []
  match do |actual|
    #
    obj = actual.recipients.collect { |item|
      expect(item).to have_attributes(:status => a_value, :messageId => a_value, :number => a_value )
    }
    (obj.all? {|e| e.eql? true} && !actual.overview.nil?)
  end
  failure_message_when_negated do |actual|
    "something went wrong. premium sms response test failing"
  end
end

RSpec::Matchers.define :inspect_FetchMessageResponse do |expected|
  status = []
  match do |actual|
    #
    obj = actual.responses.collect { |item|
      expect(item).to have_attributes(:text => a_value, :linkId => a_value, :from => a_value )
    }
    obj.all? {|e| e.eql? true}
  end
  failure_message_when_negated do |actual|
    "something went wrong. fetch sms response test failing"
  end
end


RSpec::Matchers.define :inspect_FetchSubscriptionResponse do |expected|
  status = []
  match do |actual|
    #
    obj = actual.collect { |item|
      expect(item).to have_attributes(:phoneNumber => a_value, :id => a_value, :date => a_value)
    }
    obj.all? {|e| e.eql? true}
  end
  failure_message_when_negated do |actual|
    "something went wrong. fetch sms response test failing"
  end
end


# /////////////////////////////PAYMENTS/////////////////////////////////////////////

RSpec::Matchers.define :inspect_MobileB2CResponse do |expected|
  status = []
  match do |actual|
    #
    obj = actual.collect { |item|
      expect(item).to have_attributes(:provider => a_value, :phoneNumber => a_value, :providerChannel => a_value, :transactionFee => a_value, :status => a_value, :value => a_value, :transactionId => a_value)
    }
    obj.all? {|e| e.eql? true}
  end
  failure_message_when_negated do |actual|
    "something went wrong. initiate mobile B2C response test failing"
  end
end



RSpec::Matchers.define :inspect_BankTransferResponse do |expected|
  status = []
  match do |actual|
    #
    obj = actual.entries.collect { |item|
      expect(item).to have_attributes(:accountNumber => a_value, :status => a_value, :transactionId => a_value, :transactionFee => a_value, :errorMessage => a_value)
    }
    #
    (obj.all? {|e| e.eql? true} && actual.errorMessage.nil?)

  end
  failure_message_when_negated do |actual|
    "something went wrong. bank transfer response test failing"
  end
end

# ///////////////////////// AIRTIME ////////////////////////////////////

RSpec::Matchers.define :inspect_SendAirtimeResult do |expected|
  status = []
  match do |actual|
    #
    #
    # (:errorMessage => a_value, :numSent => a_value, :totalAmount => a_value, :totalDiscount => a_value, :responses => a_value)
    if !actual.responses.nil?
      obj = actual.responses.collect { |item|
        expect(item).to have_attributes(:amount => a_value, :phoneNumber => a_value, :requestId => a_value, :status => a_value, :errorMessage => a_value, :discount => a_value)
      }
      (obj.all? {|e| e.eql? true} && !actual.totalAmount.nil? && !actual.totalDiscount.nil? && !actual.numSent.nil? && (actual.errorMessage.eql?("None") || actual.errorMessage.nil?) )
    else
      #
      !actual.totalAmount.nil? && !actual.totalDiscount.nil? && !actual.numSent.nil? && (actual.errorMessage.eql?("None") || actual.errorMessage.nil?)
    end
  end
  failure_message_when_negated do |actual|
    "something went wrong. send airtime response test failing"
  end
end

# ///////////////////////// MOBILE DATA ////////////////////////////////////

RSpec::Matchers.define :inspect_MobileDataResponse do |expected|
  status = []
  match do |actual|
    # Ensure actual is not nil before collecting
    return false if actual.nil?

    obj = actual.collect { |item|
      expect(item).to have_attributes(
        :phoneNumber => a_value,
        :provider => a_value,
        :status => a_value,
        :transactionId => a_value,
        :value => a_value
      )
    }
    obj.all? { |e| e.eql?(true) }
  end

  failure_message_when_negated do |actual|
    "something went wrong. initiate mobile data response test failing"
  end
end


# //////////////////////// VOICE /////////////////////////////////////////
RSpec::Matchers.define :inspect_CallResponse do |expected|
  status = []
  match do |actual|
    #
    #
    if !actual.entries.nil?
      obj = actual.entries.collect { |item|
        expect(item).to have_attributes(:phoneNumber => a_value, :status => a_value )
      }
      (obj.all? {|e| e.eql? true} && (actual.errorMessage.eql?("None") || actual.errorMessage.nil?))
    else
      #
      actual.errorMessage.eql?("None") || actual.errorMessage.nil?
    end
  end
  failure_message_when_negated do |actual|
    "something went wrong. call response test failing"
  end
end


RSpec::Matchers.define :inspect_QueuedCallsResponse do |expected|
  status = []
  match do |actual|
    #
    #
    if !actual.entries.nil?
      obj = actual.entries.collect { |item|
        expect(item).to have_attributes(:numCalls => a_value, :phoneNumber => a_value, :queueName => a_value)
      }
      (obj.all? {|e| e.eql? true} && !actual.status.nil? && (actual.errorMessage.eql?("None") || actual.errorMessage.nil?))
    else
      #
      actual.errorMessage.eql?("None") || actual.errorMessage.nil?
    end
  end
  failure_message_when_negated do |actual|
    "something went wrong. fetch queued calls response test failing"
  end
end
