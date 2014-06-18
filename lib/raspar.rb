require 'net/http'
require 'net/https'
require 'webrick/cookie'
require 'delegate'
require 'nokogiri'

require 'raspar/version'
require 'raspar/result'
require 'raspar/parser'
require 'raspar/dynamic_parser'

module Raspar

  def self.included(base)
    base.extend Parser::ClassMethods
    base.send :include, Parser::InstanceMethods
    base._init_parser_
  end

  class RasparException < Exception; end

  class << self

    def _init
      @parsers = {}
    end

    #Register parser class and domain
    #
    # === Example
    # Raspar::Base.register('http://test.com', TestParser)
    #
    def register(domain, klass)
      @parsers ||= {} 
      (URI(domain).host || domain).tap{ |host| @parsers[host] = klass }
    end

    # clear parser list
    def clear_parser_list
      @parsers = {}
    end

    def remove(domain)
      @parsers.delete(URI(domain).host) if @parsers
    end

    def parsers
      @parsers
    end

    def exist?(url)
      @parsers.include?(URI(url).host)
    end

    def parse(url, html)
      host = URI(url).host
      if @parsers[host]
        @parsers[host].parse(html).group_by(&:name)
      else
        puts "No parser define for #{host}"
        nil
      end
    end

    def add(url, selector_map = nil, helper_module = nil, &block)
      if self.exist?(url)
        raise RasparException.new("Parser already exist for '#{url}'")
      end

      if selector_map 
        return DynamicParser.register(url, selector_map, helper_module)
      end

      klass_name = URI(url).host
                           .split('.')
                           .reject{|w| w == 'www'}
                           .collect{|w| w[0].upcase + w[1..-1] }
                           .join
                           .gsub(/\W/, '')

      klass = Class.new
      klass.send :include, Raspar
      klass.domain(url)
      klass.class_exec(&block) if block_given?

      Raspar.const_set(klass_name, klass)
    end

  end

  #Init Raspar parser list
  self._init
end
