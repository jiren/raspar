module Raspar

  class DynamicParser
    include Parser::ClassMethods

    attr_accessor :parent_selector
    attr_reader :domain_url

    def initialize
      @fields = {}
      @common_fields = {}
      @is_dynamic_parser = true
    end

    def parse(html)
      doc = Nokogiri::HTML(html)
      common_attrs = field_parser(self, doc, common_fields)

      doc.search(parent_selector).collect do |ele|
        attrs = field_parser(self, ele, fields)
        attrs.merge!(common_attrs.clone)
        Result.new(attrs, @domain)
      end
    end

    def domain=(val)
      @domain = val
    end

    def domain_url=(val)
      @domain_url = val
    end

    def inspect
      "#<#{self.class.name} @domain=#{@domain}>"
    end

    def self.register(url, selector_map, helper_module = nil)
      dp =  self.new
      dp.domain_url = url
      dp.parent_selector = selector_map[:parent]
      selector_map[:fields].each do |field, opts|
        dp.field(field, opts)
      end
      dp.extend(helper_module) if helper_module
      dp.domain = Raspar.register(url, dp)
      dp
    end
  end

  class Result
    attr_accessor :attributes, :domain

    def initialize(attributes, domain)
      @attributes = attributes
      @domain = domain
    end

    def [](field)
      @attributes[field]
    end

    def method_missing(name, *args, &block)
      @attributes[name]
    end

  end

end
