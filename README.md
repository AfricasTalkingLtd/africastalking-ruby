
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
token.createCheckoutToken options
```
- `options`
    - `phoneNumber`: The phone number you want to create a subscription for

#### Create Checkout Token

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

### Payments
```ruby
payments = @AT.payments
```
#### Credit card checkout
```ruby
payments.cardCheckoutCharge options
```
- `options`
    - `productName`: Payment Product as setup on your account. `REQUIRED`
    - `currencyCode`: 3-digit ISO format currency code (only `NGN` is supported). `REQUIRED`
    - `amount`: Payment amount. `REQUIRED`
    - `narration`: A short description of the transaction `REQUIRED`
    - `checkoutToken`: Token that has been generated by our APIs as as result of charging a user's Payment Card in a previous transaction. When using a token, the `paymentCard` data should NOT be populated. `OPTIONAL`
    - `paymentCard`: Hash of payment Card to be charged:  `OPTIONAL`
        - `number`: The payment card number. `REQUIRED`
        - `cvvNumber`: The 3 or 4 digit Card Verification Value. `REQUIRED`
        - `expiryMonth`: The expiration month on the card (e.g `8`) `REQUIRED`
        - `expiryYear`: The expiration year on the card (e.g `2020`) `REQUIRED`
        - `authToken`: The card's ATM PIN. `REQUIRED`
        - `countryCode`: The 2-Digit countryCode where the card was issued (only `NG` is supported). `REQUIRED`
    - `metadata`: Some optional data to associate with transaction. `OPTIONAL`

#### Validate credit card checkout

```ruby
payments.cardCheckoutValidate options
```
- `options`
    - `transactionId`: The transaction that your application wants to validate. `REQUIRED`
    - `otp`: One Time Password that the card issuer sent to the client. `REQUIRED`


#### Initiate bank charge checkout
```ruby
payments.bankCheckoutCharge options
```
- `options`
    - `productName`: Payment Product as setup on your account. `REQUIRED`
    - `bankAccount`: Hash of bank account to be charged:

        - `accountName`: The name of the bank account. `REQUIRED`
        - `accountNumber`: The account number. `REQUIRED`
        - `dateOfBirth`: Date of birth of the account owner (`YYYY-MM-DD`). Required for Zenith Bank Nigeria.
        - `bankCode`: A 6-Digit [Integer Code](http://docs.africastalking.com/bank/checkout) for the bank that we allocate. Supported banks at the moment are: `REQUIRED`
        ```ruby
        payments.class::BANK_CODES['FCMB_NG']
        payments.class::BANK_CODES['ZENITH_NG']
        payments.class::BANK_CODES['ACCESS_NG']
        payments.class::BANK_CODES['PROVIDUS_NG']
        payments.class::BANK_CODES['STERLING_NG']
        ```

    - `currencyCode`: 3-digit ISO format currency code (only `NGN` is supported). `REQUIRED`
    - `amount`: Payment amount. `REQUIRED`
    - `narration`: A short description of the transaction `REQUIRED`
    - `metadata`: Some optional data to associate with transaction`OPTIONAL`


#### Validate bank checkout
```ruby
payments.bankCheckoutValidate options
```
- `options`
    - `transactionId`: The transaction that your application wants to validate. `REQUIRED`
    - `otp`: One Time Password that the bank sent to the client. `REQUIRED`


#### Bank transfer

```ruby
payments.bankTransfer options
```
- `options`
    - `productName`: Payment Product as setup on your account. `REQUIRED`
    - `recipients`: A list of recipients. Each recipient has:
    	- `bankAccount`: Bank account to be charged:
    	    - `accountName`: The name of the bank account.
    	    - `accountNumber`: The account number `REQUIRED`
    	    - `bankCode`: A 6-Digit Integer Code for the bank that we allocate; See `payments.class::BANK_CODES` for supported banks. `REQUIRED`
    	- `currencyCode`: 3-digit ISO format currency code (only `NGN` is supported). `REQUIRED`
    	- `amount`: Payment amount. `REQUIRED`
    	- `narration`: A short description of the transaction `REQUIRED`
    	- `metadata`: Some optional data to associate with transaction.

#### Mobile Checkout

```ruby
payments.mobileCheckout options
```
- `options`
    - `productName`: Your Payment Product. `REQUIRED`
    - `phoneNumber`: The customer phone number (in international format; e.g. `25471xxxxxxx`). `REQUIRED`
    - `currencyCode`: 3-digit ISO format currency code (e.g `KES`, `USD`, `UGX` etc.) `REQUIRED`
    - `amount`: This is the amount. `REQUIRED`
    - `metadata`: Some optional data to associate with transaction.`OPTIONAL`
    - `providerChannel`: This represents the payment channel the payment will be made from. eg paybill number. The payment channel must be mapped to you. The AfricasTalking default provider channel is used if not specified.`OPTIONAL`

#### Mobile B2C
```ruby
payments.mobileB2C options
```
- `options`
    - `productName`: Your Payment Product. `REQUIRED`
    - `recipients`: A list of **up to 10** recipients. Each recipient has:

        - `phoneNumber`: The payee phone number (in international format; e.g. `25471xxxxxxx`). `REQUIRED`
        - `currencyCode`: 3-digit ISO format currency code (e.g `KES`, `USD`, `UGX` etc.) `REQUIRED`
        - `amount`: Payment amount. `REQUIRED`
        - `providerChannel`: This represents the payment channel the payment will be made from. eg paybill number. The payment channel must be mapped to you. The AfricasTalking default provider channel is used if not specified.
        - `reason`: This field contains a string showing the purpose for the payment. If set, it should be one of the following
            ```
            SalaryPayment
            SalaryPaymentWithWithdrawalChargePaid
            BusinessPayment
            BusinessPaymentWithWithdrawalChargePaid
            PromotionPayment
            ```
        - `metadata`: Some optional data to associate with transaction.

#### Mobile B2B
```ruby
payments.mobileB2B options
```
- `options`
    - `productName`: Your Payment Product as setup on your account. `REQUIRED`
    - `providerData`: Hash containing Provider details. this include; `REQUIRED`

    	- `provider`: String that shows the payment provider that is facilitating this transaction. Supported providers at the moment are:
    	    
    	    ```
    	      Athena - Please note: This is not available on our production systems
    	      Mpesa

    	    ```
    	- `transferType`: This contains the payment provider that is facilitating this transaction. Supported providers at the moment are:
	       ```
	      BusinessBuyGoods
	      BusinessPayBill
	      DisburseFundsToBusiness
	      BusinessToBusinessTransfer
	       ```
    	- `destinationChannel`: This value contains the name or number of the channel that will receive payment by the provider. `REQUIRED`
    	- `destinationAccount`: This value contains the account name used by the business to receive money on the provided destinationChannel. `REQUIRED`
    - `currencyCode`: 3-digit ISO format currency code (e.g `KES`, `USD`, `UGX` etc.) `REQUIRED`
    - `amount`: Payment amount. `REQUIRED`
    - `metadata`: Some optional data to associate with transaction.`REQUIRED`

#### Mobile Data
```ruby
payments.mobileData options
```
- `options`
    - `productName`: Your Payment Product. `REQUIRED`
    - `recipients`: A list of recipients. Each recipient has:

        - `phoneNumber`: Customer phone number (in international format). `REQUIRED`
        - `quantity`: Mobile data amount. `REQUIRED`
        - `unit`: Mobile data unit. Can either be `MB` or `GB`. `REQUIRED`
        - `validity`: How long the mobile data is valid for. Must be one of `Day`, `Week` and `Month`. `REQUIRED`
        - `metadata`: Additional data to associate with the transaction. `REQUIRED`

#### Wallet Transfer
```ruby
payments.walletTransfer options
```
- `options`
    - `productName`: Your Payment Product as setup on your account. `REQUIRED`
    - `targetProductCode`: Unique code ode of payment product receiving funds on Africa's Talking `REQUIRED`
    - `currencyCode`: 3-digit ISO format currency code. `REQUIRED`
    - `amount`: Amount to transfer. `REQUIRED`
    - `metadata`: Additional data to associate with the transaction. `REQUIRED`

#### Topup Stash
```ruby
payments.topupStash options
```
- `options`
    - `productName`: Your Payment Product as setup on your account. `REQUIRED`
    - `currencyCode`: 3-digit ISO format currency code. `REQUIRED`
    - `amount`: Amount to transfer. `REQUIRED`
    - `metadata`: Additonal data to associate with the transaction. `REQUIRED`

#### Fetch Product Transactions
```ruby
payments.fetchProductTransactions options
```
- `options`
    - `productName`: Your Payment Product as setup on your account. `REQUIRED`
    - `filters`: Filters to use when fetching transactions:
        - `pageNumber`: Page number to fetch results from. Starts from `1`. `REQUIRED`
        - `count`: Number of results to fetch. `REQUIRED`
        - `startDate`: Start Date to consider when fetching
        - `endDate`: End Date to consider when fetching
        - `category`: Category to consider when fetching
        - `provider`: Provider to consider when fetching
        - `status`: Status to consider when fetching
        - `source`: Source to consider when fetching
        - `destination`: Destination to consider when fetching
        - `providerChannel`: Provider to consider when fetching

#### fetch Wallet Transactions
```ruby
payments.fetchWalletTransactions options
```
- `options`
    - `filters`: Filters to use when fetching transactions:
        - `pageNumber`: Page number to fetch results from. Starts from `1`. `REQUIRED`
        - `count`: Number of results to fetch. `REQUIRED`
        - `startDate`: Start Date to consider when fetching
        - `endDate`: End Date to consider when fetching
        - `categories`: Comma delimited list of categories to consider when fetching

#### Find Transaction
```ruby
payments.findTransaction options
```
- `options`
    - `transactionId`: ID of trancation to find `REQUIRED`

#### Fetch Wallet Balance
```ruby
payments.fetchWalletBalance
```
- Fetch your payment wallet balance


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AfricasTalkingLtd. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
