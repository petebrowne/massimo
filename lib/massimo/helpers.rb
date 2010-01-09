module Massimo
  class Helpers
    if defined? SinatraMore
      include SinatraMore::OutputHelpers
      include SinatraMore::TagHelpers
      include SinatraMore::AssetTagHelpers
      include SinatraMore::FormHelpers
      include SinatraMore::FormatHelpers
    end
    
    #
    def initialize(modules = nil)
      extend(*modules) unless modules.nil? || modules.empty?
    end
    
    # Gets the site instance
    def site
      Massimo::Site()
    end
    
    #
    def render(name, locals = {}, &block)
      site.render_view(name, locals, &block)
    end
  end
end
