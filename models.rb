require 'mongo_mapper'
require 'httparty'
require 'date'
require './exchange_rate'

class ExchangeDate < BaseExchangeRateStore
  include MongoMapper::Document

  key :date, Date
  many :rates

  def self.get_rate(date, currency)
    exchange_date = where(:date => Date.to_mongo(date), 'rates.currency' => currency).first()
    raise 'This rate does not exist' if exchange_date.nil?
    rate = exchange_date.rates.detect { |rate| rate[:currency] == currency }
    BigDecimal(rate[:rate])
  end

  def self.update_rates
    resp = HTTParty.get('http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml').parsed_response
    exchange_dates_resp = resp['Envelope']['Cube']['Cube']
    exchange_dates_resp = [exchange_dates_resp] if exchange_dates_resp.is_a?(Hash)
    exchange_dates_resp.each do |exchange_date_resp|
      date = Date.parse(exchange_date_resp['time'])
      rates = exchange_date_resp['Cube']
      exchange_date = first(:date => Date.to_mongo(date))
      if exchange_date
        exchange_date.rates = rates
        exchange_date.save
      else
        create({:date => date, :rates => rates})
      end
    end
  end
end

class Rate
  include MongoMapper::EmbeddedDocument
  key :currency, String
  key :rate, String
end
