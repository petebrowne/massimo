require 'rack/utils' # needed for sinatra_more...
require 'sinatra_more/markup_plugin'

module Massimo
  module Helpers
    include SinatraMore::OutputHelpers
    include SinatraMore::TagHelpers
    include SinatraMore::AssetTagHelpers
    include SinatraMore::FormHelpers
    include SinatraMore::FormatHelpers
    
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
