require 'rubygems'
require 'bundler/setup'
require 'open-uri'

$:.unshift(File.dirname(__FILE__) + '/../lib/')

require 'raspar'

REAL_PAGE = open('spec/html/test.htm')

class TestParser
end
