require 'sprockets'

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
      compress(output)
    end
    
    protected 
  
      def compress(javascript)
        case Massimo.config.javascripts_compressor.to_s
        when 'min', 'jsmin'
          require 'jsmin' unless defined?(JSMin)
          JSMin.minify(javascript)
        when 'pack', 'packr'
          require 'packr' unless defined?(Packr)
          options = { :shrink_vars => true }.merge Massimo.config.options_for(:packr)
          Packr.pack(javascript, options)
        when 'yui', 'yui-compressor', 'yui/compressor'
          require 'yui/compressor' unless defined?(YUI)
          options = { :munge => true }.merge Massimo.config.options_for(:yui)
          YUI::JavaScriptCompressor.new(options).compress(javascript)
        when 'closure', 'closure-compiler', 'closure/compiler'
          require 'closure-compiler' unless defined?(Closure)
          options = Massimo.config.options_for(:closure)
          Closure::Compiler.new(options).compile(javascript)
        else
          javascript
        end.strip
      end
  end
end