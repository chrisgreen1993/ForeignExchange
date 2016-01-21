require 'rubygems'
require 'bundler'

Bundler.require

require_relative 'app/app'

# Setup public directory
map '/public' do
  run Rack::Directory.new('./public')
end

# Go go go
run App
