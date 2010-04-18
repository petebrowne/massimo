require 'tilt'

module Massimo
  class View < Resource
    def render(locals = {}, &block)
      template = Tilt.new(source_path.basename.to_s) { content }
      template.render(Massimo.site.template_scope, locals, &block)
    end
  end
end
