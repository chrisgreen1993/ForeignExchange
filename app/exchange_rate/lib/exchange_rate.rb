
# ExchangeRate class for getting rates, dates and currencies + converting
# Needs to be backed by a subclass of BaseExchangeRateStore
class ExchangeRate
  class << self
    # Used to set the store to use for exchange rate data
    attr_accessor :store
  end

  # Finds the rate between the base_currency and counter_currency on date
  # Params:
  #   date: date to find rates on
  #   base_currency: The base currency, e.g 'EUR'
  #   counter_currency: The counter currency, e.g 'EUR'
  # Returns:
  #   BigDecimal containing exchange rate between base and counter
  def self.at(date, base_currency, counter_currency)
    base = BigDecimal(store.get_rate(date, base_currency))
    counter = BigDecimal(store.get_rate(date, counter_currency))
    counter / base
  end

  # Converts amount of base_currency to counter_currency
  # Params:
  #   date: date to find rates on
  #   amount: amount to convert
  #   base_currency: The base currency, e.g 'EUR'
  #   counter_currency: The counter currency, e.g 'EUR'
  # Returns:
  #   BigDecimal containing exchange rate between base and counter
  def self.convert(date, amount, base_currency, counter_currency)
    rate = self.at(date, base_currency, counter_currency)
    rate * BigDecimal(amount)
  end

  # Fetches all dates
  def self.dates
    store.get_dates
  end

  # Fetches all currencies
  def self.currencies
    store.get_currencies
  end
end

# Store which should be subclassed to provide a backing store
# Methods used in ExchangeRate
class BaseExchangeRateStore
  # Should return the rate on date for currency
  # Params:
  #   date: date to find rate for
  #   currency: currency to get rate of
  # Returns:
  #   rate on date for currency
  def self.get_rate(date, currency)
    raise NotImplementedError
  end

  # Should get all dates that have exchange data
  # Returns:
  #   Array of dates
  def self.get_dates
    raise NotImplementedError
  end

  # Should get all currencies
  # Returns:
  #   Array of currencies
  def self.get_currencies
    raise NotImplementedError
  end
end
