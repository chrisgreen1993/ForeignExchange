
class ExchangeRate

  class << self
    attr_accessor :store
  end

  def self.at(date, base, counter)
    base = store.get(date, base)
    counter = store.get(date, counter)
    counter / base
  end
end

class BaseExchangeRateStore

  def self.get(date, currency)
    raise NotImplementedError
  end

  def self.fetch
    raise NotImplementedError
  end

end
