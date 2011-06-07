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
      output = super
      output = compress(output) if Massimo.config.compress_css?
      output
    end
    
    protected 
  
      def compress(stylesheet)
        if engine_type = Crush['css']
          engine_type.new(source_path.to_s, Massimo.config.css_compressor_options) { stylesheet }.compress
        else
          stylesheet.strip
        end
      end
  end
end