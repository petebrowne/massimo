require 'sinatra_more/markup_plugin'

module Massimo
  module Helpers
    include SinatraMore::OutputHelpers
    include SinatraMore::TagHelpers
    include SinatraMore::AssetTagHelpers
    include SinatraMore::FormHelpers
    include SinatraMore::FormatHelpers
    
    def site
      Massimo.site
    end
    
    def render(view_name, locals = {})
      view = Massimo::View.find(view_name)
      view && view.render(locals)
    end
  end
end
