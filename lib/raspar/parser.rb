module Raspar
  module Parser

    module ClassMethods
      attr_reader :domain, :common_attrs, :collections

      def _init_parser_
        @common_attrs = {}
        @collections = {}
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
      def attr(name, select = nil, opts = {}, &block)
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

        if @_current_container_
          @collections[@_current_container_][:attrs][name.to_sym] = opts
        else
          @common_attrs[name.to_sym] = opts
        end
      end

      def collection(collection_name, select, &block)
        collection_name = collection_name.to_sym
        @collections[collection_name] = { :select => select, :attrs => {} } 

        @_current_container_ = collection_name
        yield if block_given?
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

      def attrs
        {:collections => @collections, :common_attrs => @common_attrs}
      end

      def info
        {:domain => @domain, :collections => @collections.keys, :common_attrs => @common_attrs.keys}
      end
    end

    module InstanceMethods
      attr_reader :attributes

      #Parse doc: html node accroding to attr selector 
      #If selector is :self then input doc is a selected doc
      #Select first 
      def attr_parser(doc, attr_map)
        attrs = {}
       
        attr_map.each do |attr_name, opts|
          ele = doc

          if opts[:select]
            if opts[:as] == :array
              attrs[attr_name] = doc.search(opts[:select]).collect{|e| process_ele(e, opts)}
            else
              opts[:select].each do |s|
                ele = doc.search(s).first
                break if ele
              end
              attrs[attr_name] = process_ele(ele, opts) if ele
            end
          else
            attrs[attr_name] = process_ele(ele, opts) if ele
          end

          #attrs[opts[:as]] ||= attrs[attr_name] if opts[:as]
        end

        attrs
      end

      def process(html, klass = nil)
        @results = []
        doc = Nokogiri::HTML(html)
        klass = self.class unless klass

        common_attrs = attr_parser(doc, klass.common_attrs)

        klass.collections.each do |name, collection|
          doc.search(collection[:select]).each do |ele|
             attrs = attr_parser(ele, collection[:attrs]).merge!(common_attrs)
             @results << Result.new(name, attrs, klass.domain)
          end
        end

        @results << Result.new(:default, common_attrs, klass.domain) if @results.none?
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
        val = opts[:prop] ? ele[opts[:prop]] : ele.content
        val.strip! if val

        if opts[:eval]
          return opts[:eval].is_a?(Symbol) ? self.send(opts[:eval], val, ele) : opts[:eval].call(val, ele)
        end

        val
      end
    end
  end
end
