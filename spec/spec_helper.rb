require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/example/'
  add_group 'gem', 'lib'
end

require 'coveralls'

Coveralls.wear!

RSpec.configure do |config|
  #config.color_enabled = true
  #config.tty = true
  #config.formatter = :documentation
end

$:.unshift(File.dirname(__FILE__) + '/../lib/')

require 'raspar'

#REAL_PAGE = open('spec/html/test.htm')

class TestParser
end
