require 'minitest/autorun'
require 'date'
require 'bigdecimal'
require 'exchange_rate'

# Fake store that just returns various values
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
    ExchangeRate.store = FakeExchangeRateStore # Setup fake store
  end

  # Tests that at method calculates rate correctly
  def test_at
    rate = ExchangeRate.at(Date.new(2016,1,1), 'USD', 'GBP')
    expected = BigDecimal('0.65433') / BigDecimal('1.6534')
    assert_equal(rate, expected)
  end

  # Tests that convert does conversion correctly
  def test_convert
    conversion = ExchangeRate.convert(Date.new(2016,1,1), '10.65', 'USD', 'GBP')
    expected = (BigDecimal('0.65433') / BigDecimal('1.6534')) * BigDecimal('10.65')
    assert_equal(conversion, expected)
  end

  # Test that currencies returns array of currencies
  def test_currencies
    currencies = ExchangeRate.currencies
    assert_equal(currencies, ['EUR', 'GBP', 'USD'])
  end

  # Test that dates returns array of dates
  def test_dates
    dates = ExchangeRate.dates
    assert_equal(dates, [Date.new(2016, 01, 01), Date.new(2015, 12, 25), Date.new(2015, 12, 12)])
  end
end

class TestBaseExchangeRateStore < Minitest::Test

  # Test that BaseExchangeRateStore raises not implemented
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
