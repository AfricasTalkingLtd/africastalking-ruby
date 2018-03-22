RSpec::Matchers.define :inspect_StatusReport do |expected|
  status = []
  match do |actual|
    status = actual.collect { |item| item.status  }
    # binding.pry
    status.find { |st| st.to_s == expected.expecteds[0][:status] }
    # binding.pry
  end

  failure_message_when_negated do |actual|
    "something went wrong. status false"
  end
end

RSpec::Matchers.define :inspect_TokenReport do |expected|
  status = []
  match do |actual|
    # status = actual.collect { |item| item.status  }
    actual.description.eql?(expected.expecteds[0][:description])
    binding.pry
    # status.find { |st| st.to_s == expected.expecteds[0][:status] }
    # binding.pry
  end

  failure_message_when_negated do |actual|
    "something went wrong. status false"
  end
end

RSpec::Matchers.define :inspect_SMSMessages do |expected|
  ids = []
  match do |actual|
    ids = actual.collect { |item| item.id  }
    # binding.pry
    ids.find { |id| id != nil || false }
  end

  failure_message_when_negated do |actual|
    "something went wrong. status false"
  end
end

RSpec::Matchers.define :inspect_AirtimeResult do |expected|
  status = []
  match do |actual|
    status = actual.collect { |item| item.status  }
    # binding.pry
    status.find { |st| st.to_s == expected.expecteds[0][:status] }
    # binding.pry
  end

  failure_message_when_negated do |actual|
    "something went wrong. status false"
  end
end

RSpec::Matchers.define :inspect_CallResponse do |expected|
  status = []
  match do |actual|
    status = actual.collect { |item| item.status  }
    # binding.pry
    status.find { |st| st.to_s == expected.expecteds[0][:status] }
    # binding.pry
  end

  failure_message_when_negated do |actual|
    "something went wrong. status false"
  end
end

RSpec::Matchers.define :inspect_QueuedCalls do |expected|
  status = []
  match do |actual|
    status = actual.collect { |item| item.status  }
    # binding.pry
    status.find { |st| st.to_s == expected.expecteds[0][:status] }
    # if actual != nil
      
    # end
    # binding.pry
  end

  failure_message_when_negated do |actual|
    "something went wrong. status false"
  end
end