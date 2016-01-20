require 'minitest/autorun'
require 'date'
require 'bigdecimal'
require './exchange_rate'

class FakeExchangeRateStore < BaseExchangeRateStore
  def self.get_rate(date, currency)
    return BigDecimal('1.6534') if currency == 'USD'
    return BigDecimal('0.65433') if currency == 'GBP'
  end

  def self.update_rates
  end
end

class TestExchangeRate < Minitest::Test

  def test_at
    ExchangeRate.store = FakeExchangeRateStore
    rate = ExchangeRate.at(Date.new(2016,1,1), 'USD', 'GBP')
    expected = BigDecimal('0.65433') / BigDecimal('1.6534')
    assert_equal(rate, expected)
  end
end

class TestBaseExchangeRateStore < Minitest::Test

  def test_get_not_implemented
    assert_raises NotImplementedError do
      BaseExchangeRateStore.get_rate(Date.today, 'USD')
    end
  end

  def test_update_rates_not_implemented
    assert_raises NotImplementedError do
      BaseExchangeRateStore.update_rates
    end
  end
end
