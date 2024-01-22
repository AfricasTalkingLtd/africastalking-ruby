
# AfricasTalking SDK

> Provides convenient access to the Africa's Talking API from applications written in ruby.

## Documentation
Take a look at the [API docs here](http://docs.africastalking.com).

[![Gem Version](https://badge.fury.io/rb/africastalking-ruby.svg)](https://badge.fury.io/rb/africastalking-ruby)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "africastalking-ruby"
```

And then execute:

    $ bundle

<!-- Or install it yourself as:

    $ gem install africastalking-ruby -->

## Usage

The SDK needs to be instantiated using your username and API key, which you can get from the [dashboard](https://account/africastalking.com).

> You can use this SDK for either production or sandbox apps. For sandbox, the app username is **ALWAYS** `sandbox`

```ruby
require "AfricasTalking"

username = 'YOUR_USERNAME' # use 'sandbox' for development in the test environment
apiKey 	= 'YOUR_API_KEY' # use your sandbox app API key for development in the test environment
@AT=AfricasTalking::Initialize.new(username, apiKey)
```

You can now make API calls using the @AT object

### Token

```ruby
token = @AT.token
```

#### Create authentication Token

```ruby
token.generateAuthToken phoneNumber
```


### Airtime

Send airtime to phone numbers

```ruby
airtime = @AT.airtime

airtime.send options
```
- `options`
    - `recipients`: Contains an hash of arrays containing the following keys
        - `phoneNumber`: Recipient of airtime `REQUIRED`
        - `currency`:3-digit ISO format currency code . `REQUIRED`
        - `amount`: Amount sent `>= 10 && <= 10K` with currency e.g `KES 100` `REQUIRED`

 - `maxNumRetry`: This allows you to specify the maximum number of retries in case of failed airtime deliveries due to various reasons such as telco unavailability. The default retry period is 8 hours and retries occur every 60seconds. For example, setting `maxNumRetry=4` means the transaction will be retried every 60seconds for the next 4 hours.`OPTIONAL`.
  
### Sms

```ruby
sms = @AT.sms
```
#### Send Sms

```ruby
sms.send options
```
- `options`
    - `message`: SMS content. `REQUIRED`
    - `to`: A single recipient or a comma separated string of recipients. `REQUIRED`
    - `from`: Shortcode or alphanumeric ID that is registered with Africa's Talking account.  `OPTIONAL`
    - `enqueue`: Set to `true` if you would like to deliver as many messages to the API without waiting for an acknowledgement from telcos. `OPTIONAL`
    - `bulkSMSMode`: This parameter will be used by the Mobile Service Provider to determine who gets billed for a message sent using a Mobile-Terminated ShortCode. The default value is 1 (which means that the sender (The AfricasTalking account being used ) gets charged). `OPTIONAL`
    - `retryDurationInHours`: t specifies the number of hours your subscription message should be retried in case it's not delivered to the subscriber. `OPTIONAL`

#### Send Premium SMS
```ruby
sms.sendPremium options
```
- `options`
    - `message`: SMS content. `REQUIRED`
    - `keyword`: The keyword to be used for a premium service. `REQUIRED`
    - `linkId`: This parameter is used for premium services to send OnDemand messages. We forward the linkId to your application when the user send a message to your service.. `REQUIRED`
    - `to`: A single recipient or a comma separated string of recipients. `REQUIRED`
    - `from`: Shortcode or alphanumeric ID that is registered with Africa's Talking account.  `OPTIONAL`
    - `enqueue`: Set to `true` if you would like to deliver as many messages to the API without waiting for an acknowledgement from telcos. `OPTIONAL`
    - `bulkSMSMode`: This parameter will be used by the Mobile Service Provider to determine who gets billed for a message sent using a Mobile-Terminated ShortCode. The default value is 1 (which means that the sender (The AfricasTalking account being used ) gets charged). `OPTIONAL`
    - `retryDurationInHours`: t specifies the number of hours your subscription message should be retried in case it's not delivered to the subscriber. `OPTIONAL`

#### Fetch Messsages

```ruby
sms.fetchMessages options
```
- `options`
    - `lastReceivedId`: This is the id of the message that you last processed. The default is 0  `OPTIONAL`

#### Create subscription

```ruby
sms.createSubcription options
```
- `options`
    - `shortCode`: This is a premium short code mapped to your account. `REQUIRED`
    - `keyword`: Value is a premium keyword under the above short code and mapped to your account. `REQUIRED`
    - `phoneNumber`: The phoneNumber to be subscribed `REQUIRED`
    - `checkoutToken`: This is a token used to validate the subscription request `REQUIRED`

#### Fetch Subscription
```ruby
sms.fetchSubscriptions options
```
- `options`
    - `shortCode`: This is a premium short code mapped to your account. `REQUIRED`
    - `keyword`: Premium keyword under the above short code and mapped to your account. `REQUIRED`
    - `lastReceivedId`: ID of the subscription you believe to be your last. Defaults to `0`

#### Delete Subscription
```ruby
sms.deleteSubscriptions options
```
- `options`
    - `shortCode`: This is a premium short code mapped to your account. `REQUIRED`
    - `keyword`: Premium keyword under the above short code and mapped to your account. `REQUIRED`
    - `phoneNumber`: PhoneNumber to be unsubscribed `REQUIRED`

### Voice
```ruby
voice = @AT.voice
```

#### Making a call
```ruby
voice.call options
```
- `options`
    - `to`: A single recipient or an array of recipients. `REQUIRED`
        - array of recipients contains ['2XXXXXXXX', '2XXXXXXXX']
    - `from`: Shortcode or alphanumeric ID that is registered with Africa's Talking account.`REQUIRED`
    - `clientRequestId`: String sent to your Events Callback URL that can be used to tag the call. `OPTIONAL`


#### Fetch queued calls
```ruby
voice.fetchQueuedCalls options
```
- `options`
    - `phoneNumber`: is phone number mapped to your AfricasTalking account. `REQUIRED`


#### Upload media file
```ruby
voice.uploadMediaFile options
```
- `options`
    - `url`: The url of the file to upload. Don't forget to start with http:// `REQUIRED`
    - `phoneNumber`: is phone number mapped to your AfricasTalking account. `REQUIRED`

### Account
```ruby
account = @AT.account
```
#### Fetch User data
```ruby
account.fetchUserData
```

### Mobile Data

Send mobile data to phone numbers

```ruby
mobiledata = @AT.mobiledata

mobiledata.send options
```
- `options`
    - `productName`:  This is the application's product name. `REQUIRED`
    - `recipients`: An array of objects containing the following keys:

        - `phoneNumber`: Recipient of the mobile data. `REQUIRED`
        - `quantity`:  a numeric value for the amount of mobile data. It is based on the available mobile data package[(see "Bundle Package" column of mobile data pricing)](https://africastalking.com/pricing). `REQUIRED`
        - `unit`: The units for the specified data quantity, the format is: ``MB`` or ``GB``. It is based on the available mobile data package[(see "Bundle Package" column of mobile data pricing)](https://africastalking.com/pricing). `REQUIRED`
        - `validity`: The period of the data bundle’s validity this can be `Day`, `Week`, `BiWeek`, `Month`, or `Quarterly`. It is based on the available mobile data package [(see "Validity" column of mobile data pricing)](https://africastalking.com/pricing). `REQUIRED`
        - `metadata`:  A JSON object of any metadata that you would like us to associate with the request. `OPTIONAL`

#### Find Transaction
```ruby
mobiledata.findTransaction options
```
- Find a mobile data transaction
- `options`
    - `transactionId`: ID of trancation to find `REQUIRED`

#### Fetch Wallet Balance
```ruby
mobiledata.fetchWalletBalance
```
- Fetch a mobile data product balance

For more information, please read the [https://developers.africastalking.com/docs/data/overview](https://developers.africastalking.com/docs/data/overview) 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AfricasTalkingLtd. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
