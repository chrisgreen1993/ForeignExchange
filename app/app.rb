require 'sinatra'
require 'bigdecimal'
require 'mongo_mapper'
require 'tilt/erb'
require_relative 'models'

class App < Sinatra::Application

  configure do
    set :views, File.dirname(__FILE__) + '/views'

    config = {'development' => {'uri' => 'mongodb://localhost/fx'}}
    MongoMapper.setup(config, 'development')
    ExchangeRate.store = ExchangeDate
  end

  get '/' do
    @dates = ExchangeRate.dates
    @currencies = ExchangeRate.currencies
    erb :index
  end

  post '/' do
    @dates = ExchangeRate.dates
    @currencies = ExchangeRate.currencies
    @params = params
    conversion = ExchangeRate.convert(
      @params[:date], @params[:amount],
      @params[:base_currency],
      @params[:counter_currency]
    ).round(2)
    @conversion_text = "#{@params[:amount]} #{@params[:base_currency]} = #{conversion} #{@params[:counter_currency]} on #{@params[:date]}"
    erb :index
  end

end
