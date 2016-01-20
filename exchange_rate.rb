
class ExchangeRate

  class << self
    attr_accessor :store
  end

  def self.at(date, base_currency, counter_currency)
    base = store.get_rate(date, base_currency)
    counter = store.get_rate(date, counter_currency)
    counter / base
  end
end

class BaseExchangeRateStore

  def self.get_rate(date, currency)
    raise NotImplementedError
  end

  def self.update_rates
    raise NotImplementedError
  end

end
