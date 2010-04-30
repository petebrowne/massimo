require 'tilt'

module Massimo
  class View < Resource
    unprocessable
    
    def render(locals = {}, &block)
      options  = Massimo.config.options_for(source_path.extname[1..-1])
      template = Tilt.new(source_path.to_s, 1, options) { content }
      template.render(Massimo.site.template_scope, locals, &block)
    end
  end
end
