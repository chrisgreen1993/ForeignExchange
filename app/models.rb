require 'mongo_mapper'
require 'httparty'
require 'date'
require 'exchange_rate'

# Model class to represent a certain day of exchange rates
# Contains date and array of subdocuments containing currency and rate
class ExchangeDate < BaseExchangeRateStore
  include MongoMapper::Document

  key :date, Date
  many :rates

  # Gets rate for currency on date from Mongo
  # See BaseExchangeRateStore
  def self.get_rate(date, currency)
    exchange_date = where(:date => Date.to_mongo(date), 'rates.currency' => currency).first()
    raise 'This rate does not exist' if exchange_date.nil?
    rate = exchange_date.rates.detect {|rate| rate[:currency] == currency}
    BigDecimal(rate[:rate])
  end

  # Gets all dates from mongo - newest first
  # See BaseExchangeRateStore
  def self.get_dates
    exchange_dates = all()
    dates = exchange_dates.map {|exchange_date| exchange_date[:date]}
    dates.sort.reverse!
  end

  # Gets all currencies from mongo - sorted alphabetically
  # See BaseExchangeRateStore
  def self.get_currencies
    exchange_dates = all()
    rates = exchange_dates.map {|exchange_date| exchange_date.rates.map {|rate| rate[:currency]}}
    rates.flatten.uniq.sort
  end

  # Fetches latest rates from European Central Bank api and stores in mongo
  def self.update_rates
    resp = HTTParty.get('http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml').parsed_response
    exchange_dates_resp = resp['Envelope']['Cube']['Cube']
    # If there's a singe item then it is a hash, so we need to whack it in an array
    exchange_dates_resp = [exchange_dates_resp] if exchange_dates_resp.is_a?(Hash)
    exchange_dates_resp.each do |exchange_date_resp|
      date = Date.parse(exchange_date_resp['time'])
      rates = exchange_date_resp['Cube']
      rates << {:currency => 'EUR', :rate => '1'} # ECB API doesn't contain EUR so add manually
      exchange_date = first(:date => Date.to_mongo(date))
      if exchange_date
        # Update existing dates rates in case they changed
        exchange_date.rates = rates
        exchange_date.save
      else
        create({:date => date, :rates => rates})
      end
    end
  end
end

# Embedded within ExchangeDate
class Rate
  include MongoMapper::EmbeddedDocument
  key :currency, String
  key :rate, String
end
