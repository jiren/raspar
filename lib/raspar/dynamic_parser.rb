module Raspar

  class DynamicParser
    include Parser::InstanceMethods
    include Parser::ClassMethods

    attr_accessor :domain, :domain_url, 
      :common_attrs, :collections, :_current_container_

    def initialize
      @common_attrs = {}
      @collections = {}
    end

    def parse(html)
      self.process(html, self)
    end

    def self.register(url, selector_map, helper_module = nil)
      dp =  self.new

      if selector_map[:common_attrs]
        selector_map[:common_attrs].each { |attr, opts| dp.attr(attr, opts) }
      end

      if selector_map[:collections]
        selector_map[:collections].each do |name, collection_opts|
          dp.collections[name] = { :select => collection_opts[:select], :attrs => {} }

          dp._current_container_ = name.to_sym
          collection_opts[:attrs].each { |attr, opts| dp.attr(attr, opts) } 
          dp._current_container_ = nil
        end
      end

      #TODO: Create constant from string and extend object.
      dp.extend(helper_module) if helper_module
      dp.domain_url = url
      dp.domain = Raspar.register(url, dp)
      dp
    end
  end

end
