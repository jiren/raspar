module Raspar
  module Parser

    module ClassMethods
      attr_accessor :fields, :common_fields, :is_dynamic_parser
      attr_reader :domain_url

      def _init_parser_
        @fields = {}
        @common_fields = {}
      end

      #
      # name  // opts = {:select => nil} 
      # name, '.name' // opts = {:select => ['.name']}
      # name, '.name, .title' // opts = {:select => ['.name', '.title']}
      # name, ['.name', .title] // opts = {:select => ['.name', '.title']}
      # name, '.name', {:eval => :parse_name, :attr => 'name'} 
      #   opts = {:eval => :parse_name, :attr => 'name', :select => ['.name']}
      # name, {:eval => :parse_name, :attr => 'name'} 
      #   opts = {:eval => :parse_name, :attr => 'name', :select => nil}
      def field(name, select = nil, opts = {}, &block)
        if select.is_a?(Hash)
          opts = select
        else
          opts[:select] = select
        end

        opts[:select] = case opts[:select]
                        when Array
                          opts[:select].flatten
                        when String
                          opts[:select].split(',').collect(&:strip)
                        else
                          opts[:select]
                        end

        opts[:select] = opts[:select].join(',') if opts[:as] == :array
        opts[:eval] = opts[:eval].to_sym if opts[:eval].is_a?(String)
        opts[:eval] = block if block_given?

        opts[:common] ? @common_fields[name.to_sym] = opts : @fields[name.to_sym] = opts
      end

      def field_names
        @common_fields.keys + @fields.keys
      end

      def parent(selector)
        @parent_selector = selector if @parent_selector.nil?
      end

      def domain(url = nil)
        if url 
          @domain_url = url
          @domain = Raspar.register(url, self)
        end
        @domain
      end

      def absolute_url(path)
        URI(@domain_url).merge(path).to_s
      end

      def parse(html)
        doc = Nokogiri::HTML(html)
        #common_attrs = self.field_parser(self, doc, self.common_fields)

        doc.search(@parent_selector).collect do |ele|
          self.new.process(doc, ele)
        end
      end

      def info
        {:parent => @parent_selector, :domain => @domain}
      end

      def inspect
        "#<#{self.name} @domain=#{@domain}>"
      end

      #Parse doc: html node accroding to field selector 
      #If selector is :self then input doc is a selected doc
      #Select first 
      def field_parser(klass, doc, field_map)
        attrs = {}

        field_map.each do |field_name, opts|
          ele = doc

          if opts[:select]
            if opts[:as] == :array
              attrs[field_name] = doc.search(opts[:select]).collect{|e| process_ele(klass, e, opts)}
            else
              opts[:select].each do |s|
                ele = doc.search(s).first
                break if ele
              end
              attrs[field_name] = process_ele(klass, ele, opts) if ele
            end
          else
            attrs[field_name] = process_ele(klass, ele, opts) if ele
          end

          #attrs[opts[:as]] ||= attrs[field_name] if opts[:as]

        end

        attrs
      end

      private 

      #Process selected html element
      #
      #- If process is false and check eval is present then pass 
      #  element to eval proc else html ele return and assign to 
      #  attribute.
      #- If process is false then :value option not going to evaluate.
      def process_ele(klass, ele, opts)
        val = opts[:attr] ? ele[opts[:attr]] : ele.content
        val.strip! if val
        
        if opts[:eval]
          return opts[:eval].is_a?(Symbol) ? klass.send(opts[:eval], val, ele) : opts[:eval].call(val, ele)
        end

        val
      end

      def _define_field_(name)
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{name}
            @attributes[:#{name}]
          end

          def #{name}=(val)
            @attributes[:#{name}] = val 
          end
        METHOD
      end

    end

    module InstanceMethods
      attr_reader :doc, :attributes

      def process(doc, ele)
        klass = self.class
        @attributes = klass.field_parser(self, ele, klass.fields)
        @attributes.merge!(klass.field_parser(self, doc, klass.common_fields))
        self
      end

      def to_h
        @attributes
      end

      def [](field)
        @attributes[field]
      end

      def method_missing(name, *args, &block)
        @attributes[name]
      end

    end

  end
end
