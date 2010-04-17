module Massimo
  class Site
    attr_accessor :config
    
    DEFAULT_RESOURCES = [ Massimo::Page ].freeze
    
    def initialize(options = nil)
      @config = Config.new(options)
      yield @config if block_given?
      Massimo.site = self
    end
    
    def resources
      @resources ||= DEFAULT_RESOURCES.dup
    end
    
    def resource(name_or_class, &block)
      resource = case name_or_class
        when Class
          name_or_class
        else
          Object.const_set name_or_class.to_s.classify, Class.new(Massimo::Page, &block)
        end
      resources << resource
    end
  end
end
