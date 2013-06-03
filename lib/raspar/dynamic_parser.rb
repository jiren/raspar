module Raspar

  class DynamicParser
    include Parser::InstanceMethods
    include Parser::ClassMethods

    attr_accessor :domain, :domain_url, 
      :common_fields, :item_containers, :_current_container_

    def initialize
      @common_fields = {}
      @item_containers = {}
    end

    def parse(html)
      self.process(html, self)
    end

    def self.register(url, selector_map, helper_module = nil)
      dp =  self.new

      if selector_map[:common_fields]
        selector_map[:common_fields].each { |field, opts| dp.field(field, opts) }
      end

      if selector_map[:item_containers]
        selector_map[:item_containers].each do |name, item_opts|
          dp.item_containers[name] = { :select => item_opts[:select], :fields => {} }

          dp._current_container_ = name.to_sym
          item_opts[:fields].each { |field, opts| dp.field(field, opts) } 
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
