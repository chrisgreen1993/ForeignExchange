
class ExchangeRate
  class << self
    attr_accessor :store
  end

  def self.at(date, base_currency, counter_currency)
    base = BigDecimal(store.get_rate(date, base_currency))
    counter = BigDecimal(store.get_rate(date, counter_currency))
    counter / base
  end

  def self.convert(date, amount, base_currency, counter_currency)
    rate = self.at(date, base_currency, counter_currency)
    rate * BigDecimal(amount)
  end

  def self.dates
    store.get_dates
  end

  def self.currencies
    store.get_currencies
  end
end

class BaseExchangeRateStore
  def self.get_rate(date, currency)
    raise NotImplementedError
  end

  def self.get_dates
    raise NotImplementedError
  end

  def self.get_currencies
    raise NotImplementedError
  end
end
