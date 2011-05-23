require 'tilt'

module Massimo
  class View < Resource
    unprocessable
    
    def render(locals = {}, &block)
      template_options = Massimo.config.options_for(extension[1..-1])
      template         = Tilt.new(source_path.to_s, 1, template_options) { content }
      template.render(template_scope, locals, &block)
    end
  end
end