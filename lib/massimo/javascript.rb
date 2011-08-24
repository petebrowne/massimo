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
      if source_path.extname == '.js'
        options = Massimo.config.options_for(:sprockets).merge(
          :assert_root  => Massimo.config.output_path,
          :source_files => [ source_path.to_s ]
        )
        secretary = Sprockets::Secretary.new(options)
        secretary.install_assets
        @content = secretary.concatenation.to_s
      end
      super
    end
  end
end