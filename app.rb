require 'sinatra'
require 'mongo_mapper'
require './models'

config = {'development' => {'uri' => 'mongodb://localhost/fx'}}
MongoMapper.setup(config, 'development')

get '/' do
  'HELLO WORLD'
end
