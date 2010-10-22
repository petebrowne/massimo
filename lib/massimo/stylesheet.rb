module Massimo
  class Stylesheet < Massimo::Resource
    def render
      case source_path.extname
      when '.sass', '.scss'
        require 'sass' unless defined?(Sass)
        options = Massimo.config.options_for(:sass).merge(:css_filename => output_path)
        Sass::Files.tree_for(source_path.to_s, options).render
      when '.less'
        require 'less' unless defined?(Less)
        Less::Engine.new(content, Massimo.config.options_for(:less)).to_css
      else
        super
      end
    end
    
    def extension
      @extension ||= '.css'
    end
  end
end