require 'minitest/autorun'
require 'webmock'
require 'mongo_mapper'
require './models'

class TestExchangeDate < Minitest::Test
  include WebMock::API

  def setup
    config = {'test' => {'uri' => 'mongodb://localhost/fx_test'}}
    MongoMapper.setup(config, 'test')
    ExchangeDate.create({:date => Date.new(2016,1,1), :rates => [{ :currency => 'USD', :rate => '1.566' }, { :currency => 'GBP', :rate => '2.765'}]})
  end

  def teardown
    ExchangeDate.delete_all
  end

  def test_update_rates_new
    xml = %{
      <?xml version="1.0" encoding="UTF-8"?>
      <gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">
        <gesmes:subject>Reference rates</gesmes:subject>
        <gesmes:Sender>
          <gesmes:name>European Central Bank</gesmes:name>
        </gesmes:Sender>
        <Cube>
          <Cube time="2016-01-19">
            <Cube currency="USD" rate="1.0868"/>
            <Cube currency="GBP" rate="128.12"/>
          </Cube>
          <Cube time="2016-01-18">
            <Cube currency="USD" rate="1.7356"/>
            <Cube currency="GBP" rate="1.1256"/>
          </Cube>
        </Cube>
      </gesmes:Envelope>
    }
    stub_request(:get, 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml')
      .to_return(:body => xml, :status => 200, :headers => {'content-type' => 'text/xml'})
    ExchangeDate.update_rates
    exchange_dates = ExchangeDate.all
    assert_equal(exchange_dates.length, 3)
    assert_equal(exchange_dates[1]['date'], Date.new(2016, 01, 19))
    assert_equal(exchange_dates[1].rates.length, 2)
    rates = exchange_dates[1].rates
    assert_equal(rates[0]['currency'], 'USD')
    assert_equal(rates[0]['rate'], '1.0868')
    assert_equal(rates[1]['currency'], 'GBP')
    assert_equal(rates[1]['rate'], '128.12')
    assert_equal(exchange_dates[2]['date'], Date.new(2016, 01, 18))
    assert_equal(exchange_dates[2].rates.length, 2)
    rates = exchange_dates[2].rates
    assert_equal(rates[0]['currency'], 'USD')
    assert_equal(rates[0]['rate'], '1.7356')
    assert_equal(rates[1]['currency'], 'GBP')
    assert_equal(rates[1]['rate'], '1.1256')
  end

  def test_update_rates_existing
    xml = %{
      <?xml version="1.0" encoding="UTF-8"?>
      <gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">
        <gesmes:subject>Reference rates</gesmes:subject>
        <gesmes:Sender>
          <gesmes:name>European Central Bank</gesmes:name>
        </gesmes:Sender>
        <Cube>
          <Cube time="2016-01-01">
            <Cube currency="USD" rate="1.0868"/>
            <Cube currency="GBP" rate="128.12"/>
          </Cube>
        </Cube>
      </gesmes:Envelope>
    }
    stub_request(:get, 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml')
      .to_return(:body => xml, :status => 200, :headers => {'content-type' => 'text/xml'})
    ExchangeDate.update_rates
    exchange_dates = ExchangeDate.all
    assert_equal(exchange_dates.length, 1)
    assert_equal(exchange_dates[0]['date'], Date.new(2016, 01, 01))
    assert_equal(exchange_dates[0].rates.length, 2)
    rates = exchange_dates[0].rates
    assert_equal(rates[0]['currency'], 'USD')
    assert_equal(rates[0]['rate'], '1.0868')
    assert_equal(rates[1]['currency'], 'GBP')
    assert_equal(rates[1]['rate'], '128.12')
  end

  def test_get_rate
    ExchangeDate.create({:date => Date.new(2015, 12, 05), :rates => [{:currency => 'USD', :rate => '1.5678'}, {:currency => 'GBP', :rate => '6.6789'}]})
    rate = ExchangeDate.get_rate(Date.new(2016, 01, 01), 'USD')
    assert_equal(rate, BigDecimal('1.566'))
  end

  def test_get_rate_no_rate
    exception = assert_raises RuntimeError do
      ExchangeDate.get_rate(Date.new(2013, 01, 01), 'USD')
    end
    assert_equal('This rate does not exist', exception.message)
  end
end
