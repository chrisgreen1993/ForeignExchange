require 'rubygems'
require 'bundler'

Bundler.require

require 'rake/testtask'
require_relative 'app/app'

# Updates exchange rates, should be run on daily cron
task :update_exchange_rates do
  ExchangeDate.update_rates
end

# Runs tests
Rake::TestTask.new do |t|
  t.test_files = FileList["test/test_*.rb", "app/exchange_rate/test/test_*.rb"]
end
