module Massimo
  module Helpers
    #
    def render(name, locals = {})
      self.site.render_view(name, locals)
    end
  end
end
