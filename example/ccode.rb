require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'raspar'
require 'pp'

class CCode
  include Raspar

  domain 'http://www.exchange-rate.com'
  parent 'table[cellpadding="2"] tr:gt(1)'

  field :country,  'td:nth-child(1)'
  field :currency, 'td:nth-child(2)'
  field :code,     'td:nth-child(3)'
end

url = 'http://www.exchange-rate.com/currency-list.html' 
page = open(@url).read

Raspar.parse(url, page).each do |i|
  pp i.attributes
end
