require 'rake/testtask'
require_relative 'app/app'

# Updates exchange rates, should be run on daily cron
task :update_exchange_rates do
  ExchangeDate.update_rates
end

# Runs tests
Rake::TestTask.new do |t|
  t.pattern = "test/test_*.rb"
end
