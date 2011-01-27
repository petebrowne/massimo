require 'rack/utils' # needed for sinatra_more...
require 'padrino-helpers'

module Massimo
  module Helpers
    include Padrino::Helpers::DomHelpers
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
    
    # Renders a view with the given locals. Kind of like `render :partial` in Rails
    def render(view_name, locals = {})
      view = Massimo::View.find(view_name)
      view && view.render(locals)
    end
  end
end