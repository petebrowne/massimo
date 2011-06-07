require 'crush'
require 'sprockets'
require 'tilt'

module Massimo
  class Javascript < Massimo::Resource
    def extension
      if Tilt.registered?(super[1..-1])
        '.js'
      else
        super
      end
    end
    
    def render
      output = if source_path.extname == '.js'
          options = Massimo.config.options_for(:sprockets).merge(
            :assert_root  => Massimo.config.output_path,
            :source_files => [ source_path.to_s ]
          )
          secretary = Sprockets::Secretary.new(options)
          secretary.install_assets
          secretary.concatenation.to_s
        else
          super
        end
      output = compress(output) if Massimo.config.compress_js?
      output
    end
    
    protected 
  
      def compress(javascript)
        if engine_type = Crush['js']
          engine_type.new(source_path.to_s, Massimo.config.js_compressor_options) { javascript }.compress
        else
          javascript.strip
        end
      end
  end
end