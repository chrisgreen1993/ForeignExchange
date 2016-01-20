
class ExchangeRate

  class << self
    attr_accessor :store
  end

  def self.at(date, base_currency, counter_currency)
    base = store.get_rate(date, base_currency)
    counter = store.get_rate(date, counter_currency)
    counter / base
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

  def self.update_rates
    raise NotImplementedError
  end

end
