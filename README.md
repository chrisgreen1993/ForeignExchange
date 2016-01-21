# Foreign Exchange

Sinatra web app for converting currencies and exchange_rate library. Backed by mongoDB.

## Usage

Ruby version 2.3.0, MongoDB version 3.2.0

Start mongoDB

`mongod`

Install dependencies

`gem install bundler`

`bundle install`

Run unit tests

`rake test`

Fetch latest exchange rates and store in db

`rake update_exchange_rates`

Start webserver

`rackup`

Open web browser @ localhost

## Design decisions

The exchange_rate gem is stored in `app/exchange_rate` and is installed with `bundle install` (in reality this would be on rubygems). This gem has 2 classes, the ExchangeRate class which allows the user to find the exchange rate, convert etc and the BaseExchangeRateStore class, which the user must subclass and implement the required methods. This allows the ExchangeRate class to be backed by different stores easily.

In `app/models.rb` are the models. The ExchangeDate model inherits from BaseExchangeRateStore and implements its methods. to get rates, dates, currencies. It also has a method to update the rates in the db from the ECB api. This would be run via a cron job.

I decided to use mongoDB as the data from the ECB was nested, so it would be easier to represent it as a document and an array of subdocuments, rather than having to setup 2 tables with a join using SQL.

`app/app.rb` contains the routes for the app and a bit of setup. I used sinatra for this as Rails would have been total overkill for 2 routes.
