require 'net/http'
require 'net/https'
require 'webrick/cookie'
require 'delegate'
require 'nokogiri'

require 'raspar/version'
require 'raspar/base'
require 'raspar/parser'
require 'raspar/dynamic_parser'

module Raspar

  def self.included(base)
    base.extend Parser::ClassMethods
    base.send :include, Parser::InstanceMethods
    base._init_parser_
  end

  class << self

    #Register parser class and domain
    #
    # === Example
    # Raspar::Base.register('http://test.com', TestParser)
    #
    def register(domain, klass)
      @parser_list ||= {} 
      (URI(domain).host || domain).tap{ |host| @parser_list[host] = klass }
    end

    # clear parser list
    def clear
      @parser_list = {}
    end

    def remove(domain)
      @parser_list.delete(URI(domain).host) if @parser_list
    end

    def parser_list
      @parser_list
    end

    def parse(url, html)
      host = URI(url).host
      if @parser_list[host]
        @parser_list[host].parse(html)
      else
        puts "No parser define for #{url}"
      end
    end

    def add_parsing_map(url, selector_map, helper_module = nil)
      DynamicParser.register(url, selector_map, helper_module)
    end

  end

end
