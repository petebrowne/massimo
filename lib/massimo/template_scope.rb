module Massimo
  class TemplateScope
    if defined? ::SinatraMore
      include ::SinatraMore::OutputHelpers
      include ::SinatraMore::TagHelpers
      include ::SinatraMore::AssetTagHelpers
      include ::SinatraMore::FormHelpers
      include ::SinatraMore::FormatHelpers
    end
    include ::Massimo::Helpers
    
    #
    def initialize(modules = [])
      modules.each { |m| self.class.send(:include, m) }
    end
    
    # Gets the site instance
    def site
      Massimo::Site()
    end
  end
end
