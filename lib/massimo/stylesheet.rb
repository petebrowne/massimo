module Massimo
  class Stylesheet < Massimo::Resource
    def render
      case source_path.extname.to_s
      when '.sass', '.scss'
        require 'sass' unless defined?(Sass)
        Sass::Files.tree_for(source_path.to_s, :css_filename => output_path).render
      when '.less'
        require 'less' unless defined?(Less)
        Less::Engine.new(content).to_css
      else
        super
      end
    end
    
    def extension
      @extension ||= '.css'
    end
  end
end
