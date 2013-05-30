require 'rubygems'
require 'bundler/setup'
require 'open-uri'

RSpec.configure do |config|
  config.color_enabled = true
  #config.tty = true
  #config.formatter = :documentation
end

$:.unshift(File.dirname(__FILE__) + '/../lib/')

require 'raspar'

#REAL_PAGE = open('spec/html/test.htm')

class TestParser
end
