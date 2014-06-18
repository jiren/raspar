require 'rubygems'
require 'rest_client'
require 'bundler/setup'
require 'raspar'
require 'pp'

class CountryCode
  include Raspar

  domain 'http://www.exchange-rate.com'

  collection :currency_code, 'table[cellpadding="2"] tr:gt(1)' do
    attr :country,  'td:nth-child(1)'
    attr :currency, 'td:nth-child(2)'
    attr :code,     'td:nth-child(3)'
  end
end

url = 'http://www.exchange-rate.com/currency-list.html' 
page = RestClient.get(url).to_str

Raspar.parse(url, page).each {|i| pp i }
