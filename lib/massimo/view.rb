require 'tilt'

module Massimo
  class View < Resource
    unprocessable
    
    def render(locals = {}, &block)
      file_path = source_path.to_s.sub(/^#{Regexp.escape(Massimo.config.source_path)}/, '')
      template  = Tilt.new(file_path) { content }
      template.render(Massimo.site.template_scope, locals, &block)
    end
  end
end
