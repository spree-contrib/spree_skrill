# Spree Skrill (Moneybookers)

Add support for Skrill / MoneyBookers Quick checkout as a payment
method.

## Installation

1. Add the following to your Gemfile

<pre>
    gem 'spree_skrill', :git => 'git://github.com/spree/spree_skrill.git', :branch => '0-60-stable'
</pre>

2. Run `bundle install`

3. To copy migrations run: `rake spree_skrill:install`

4. Run migration `rake db:migrate`

## Configuring

1. Add a new Payment Method, using: `BillingIntegration::Skrill::QuickCheckout` as the `Prodivder`

2. Click `Create`, and enter your Store's Skrill / MoneyBookers Merchant
   ID (also called Customer ID) in the field provide.

3. `Save` and enjoy!


Testing
-------

Be sure to add the rspec-rails gem to your Gemfile and then create a dummy test app for the specs to run against.

    $ bundle exec rake test app
    $ bundle exec rspec spec

Copyright (c) 2011 [name of extension creator], released under the New BSD License
