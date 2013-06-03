module Raspar
  module Parser

    module ClassMethods
      attr_reader :domain, :common_fields, :item_containers

      def _init_parser_
        @common_fields = {}
        @item_containers = {}
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

        #opts[:common] ? @common_fields[name.to_sym] = opts : @fields[name.to_sym] = opts
        if @_current_container_
          @item_containers[@_current_container_][:fields][name.to_sym] = opts
        else
          @common_fields[name.to_sym] = opts
        end
      end

      def item(item_name, select, &block)
        item_name = item_name.to_sym
        @item_containers[item_name] = { :select => select, :fields => {} } 

        @_current_container_ = item_name
        yield
        @_current_container_ = nil
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
        self.new.process(html)
      end

      def fields
        {:item_containers => @item_containers, :common_fields => @common_fields}
      end

      def info
        {:domain => @domain, :item_containers => @item_containers.keys, :common_fields => @common_fields.keys}
      end
    end

    module InstanceMethods
      attr_reader :attributes

      #Parse doc: html node accroding to field selector 
      #If selector is :self then input doc is a selected doc
      #Select first 
      def field_parser(doc, field_map)
        attrs = {}
       
        field_map.each do |field_name, opts|
          ele = doc

          if opts[:select]
            if opts[:as] == :array
              attrs[field_name] = doc.search(opts[:select]).collect{|e| process_ele(e, opts)}
            else
              opts[:select].each do |s|
                ele = doc.search(s).first
                break if ele
              end
              attrs[field_name] = process_ele(ele, opts) if ele
            end
          else
            attrs[field_name] = process_ele(ele, opts) if ele
          end

          #attrs[opts[:as]] ||= attrs[field_name] if opts[:as]
        end

        attrs
      end

      def process(html, klass = nil)
        @results = []
        doc = Nokogiri::HTML(html)
        klass = self.class unless klass

        common_attrs = field_parser(doc, klass.common_fields)

        klass.item_containers.each do |name, item|
          doc.search(item[:select]).each do |ele|
             attrs = field_parser(ele, item[:fields]).merge!(common_attrs)
             @results << Result.new(name, attrs, klass.domain)
          end
        end

        @results
      end

      private 

      #Process selected html element
      #
      #- If process is false and check eval is present then pass 
      #  element to eval proc else html ele return and assign to 
      #  attribute.
      #- If process is false then :value option not going to evaluate.
      def process_ele(ele, opts)
        val = opts[:attr] ? ele[opts[:attr]] : ele.content
        val.strip! if val

        if opts[:eval]
          return opts[:eval].is_a?(Symbol) ? self.send(opts[:eval], val, ele) : opts[:eval].call(val, ele)
        end

        val
      end


    end

  end
end
