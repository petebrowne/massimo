require 'tilt'

module Massimo
  class View < Resource
    def render(locals = {}, &block)
      Tilt.new(source_path.basename.to_s).render(nil, locals, &block)
    end
  end
end
