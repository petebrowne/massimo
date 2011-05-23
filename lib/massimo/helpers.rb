require 'padrino-helpers'

module Massimo
  module Helpers
    include Padrino::Helpers::OutputHelpers
    include Padrino::Helpers::TagHelpers
    include Padrino::Helpers::AssetTagHelpers
    include Padrino::Helpers::FormHelpers
    include Padrino::Helpers::FormatHelpers
    include Padrino::Helpers::NumberHelpers
    include Padrino::Helpers::TranslationHelpers
    
    # Returns an instance of the Site
    def site
      Massimo.site
    end
    
    # Returns the current Site configuration
    def config
      Massimo.config
    end
    
    # Renders a view with the given locals. Kind of like `render :partial` in Rails
    def render(view_name, locals = {})
      view = Massimo::View.find(view_name)
      view && view.render(locals)
    end
  end
end