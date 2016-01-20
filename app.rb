require 'sinatra'
require 'bigdecimal'
require 'mongo_mapper'
require 'erb'
require './models'

config = {'development' => {'uri' => 'mongodb://localhost/fx'}}
MongoMapper.setup(config, 'development')
ExchangeRate.store = ExchangeDate

get '/' do
  @dates = ExchangeRate.dates
  puts @dates.first
  @currencies = ExchangeRate.currencies
  erb :index
end

post '/' do
  @dates = ExchangeRate.dates
  @currencies = ExchangeRate.currencies
  @params = params
  rate = ExchangeRate.at(@params[:date], @params[:base_currency], @params[:counter_currency])
  conversion = (rate * BigDecimal(@params[:amount])).round(2)
  @conversion_text = "#{@params[:amount]} #{@params[:base_currency]} = #{conversion} #{@params[:counter_currency]} on #{@params[:date]}"
  erb :index
end
