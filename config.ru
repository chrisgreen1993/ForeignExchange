require 'rubygems'
require 'bundler'

Bundler.require

require_relative 'app/app'

map '/public' do
  run Rack::Directory.new('./public')
end

run App
