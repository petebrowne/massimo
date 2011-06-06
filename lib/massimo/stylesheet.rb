require 'crush'
require 'tilt'

module Massimo
  class Stylesheet < Massimo::Resource
    def extension
      if Tilt.registered?(super[1..-1])
        '.css'
      else
        super
      end
    end
    
    def render
      compress(super)
    end
    
    protected 
  
      def compress(stylesheet)
        if engine_type = Crush.find_by_name(Massimo.config.css_compressor)
          engine_type.new(source_path.to_s, Massimo.config.css_compressor_options) { stylesheet }.compress
        else
          stylesheet.strip
        end
      end
  end
end