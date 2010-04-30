require 'tilt'

module Massimo
  class View < Resource
    unprocessable
    
    def render(locals = {}, &block)
      template = Tilt.new(source_path.to_s) { content }
      template.render(Massimo.site.template_scope, locals, &block)
    end
  end
end
