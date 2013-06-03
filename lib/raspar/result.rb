module Raspar
  class Result
    attr_reader :name, :attrs, :domain

    def initialize(name, attrs, domain = nil)
      @name = name
      @attrs = attrs
      @domain = domain if domain
    end

    def [](f)
      @attrs[f]
    end

    def method_missing(name, *args, &block)
      @attrs[name]
    end

  end
end
