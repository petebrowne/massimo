module Massimo
  class Site
    attr_accessor :config
    
    def initialize(options = nil)
      @config = Config.new(options)
      yield @config if block_given?
      Massimo.site = self
    end
    
    def resources
      @resources ||= [ Massimo::Page, Massimo::Javascript, Massimo::Stylesheet ]
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
    
    def template_scope
      @template_scope ||= Object.new.extend(Massimo::Helpers)
    end
    
    def helpers(*extensions, &block)
      template_scope.instance_eval &block if block_given?
      template_scope.extend(*extensions) if extensions.any?
    end
  end
end
