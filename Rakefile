require 'rake/testtask'
require_relative 'app/app'

task :update_exchange_rates do
  ExchangeDate.update_rates
end

Rake::TestTask.new do |t|
  t.pattern = "test/test_*.rb"
end
