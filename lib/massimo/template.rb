module Massimo
  class Template
    if defined? ::SinatraMore
      include ::SinatraMore::OutputHelpers
      include ::SinatraMore::TagHelpers
      include ::SinatraMore::AssetTagHelpers
      include ::SinatraMore::FormHelpers
      include ::SinatraMore::FormatHelpers
    end
    
    #
    def initialize(modules = [])
      modules.each { |m| self.class.send(:include, m) }
    end
    
    # Add local variables to this template and return the binding
    def local_binding(locals = {})
      locals.each do |key, value|
        self.class.send(:define_method, key) { value }
      end
      self.send(:binding)
    end
  end
end
