require 'minitest/autorun'
require 'date'
require 'bigdecimal'
require_relative '../app/lib/exchange_rate'

class FakeExchangeRateStore < BaseExchangeRateStore
  def self.get_rate(date, currency)
    return BigDecimal('1.6534') if currency == 'USD'
    return BigDecimal('0.65433') if currency == 'GBP'
  end

  def self.get_dates
    [Date.new(2016, 01, 01), Date.new(2015, 12, 25), Date.new(2015, 12, 12)]
  end

  def self.get_currencies
    ['EUR', 'GBP', 'USD']
  end

end

class TestExchangeRate < Minitest::Test

  def setup
    ExchangeRate.store = FakeExchangeRateStore
  end

  def test_at
    rate = ExchangeRate.at(Date.new(2016,1,1), 'USD', 'GBP')
    expected = BigDecimal('0.65433') / BigDecimal('1.6534')
    assert_equal(rate, expected)
  end

  def test_convert
    conversion = ExchangeRate.convert(Date.new(2016,1,1), '10.65', 'USD', 'GBP')
    expected = (BigDecimal('0.65433') / BigDecimal('1.6534')) * BigDecimal('10.65')
    assert_equal(conversion, expected)
  end

  def test_currencies
    currencies = ExchangeRate.currencies
    assert_equal(currencies, ['EUR', 'GBP', 'USD'])
  end

  def test_dates
    dates = ExchangeRate.dates
    assert_equal(dates, [Date.new(2016, 01, 01), Date.new(2015, 12, 25), Date.new(2015, 12, 12)])
  end
end

class TestBaseExchangeRateStore < Minitest::Test

  def test_not_implemented
    assert_raises NotImplementedError do
      BaseExchangeRateStore.get_rate(Date.today, 'USD')
    end
    assert_raises NotImplementedError do
      BaseExchangeRateStore.get_dates
    end
    assert_raises NotImplementedError do
      BaseExchangeRateStore.get_currencies
    end

  end
end
