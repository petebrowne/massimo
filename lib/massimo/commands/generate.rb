require 'active_support/core_ext/string/starts_ends_with'
require 'active_support/inflector'

module Massimo
  module Commands
    class Generate < Base
      def banner
%{
#{Massimo::UI.color('massimo generate SITE_OR_RESOURCE [FILE]', :cyan)}
Generates a new site:
  massimo generate myblog
Within a massimo project, you can generate a new resource file:
  massimo generate page contact.haml
}
      end
      
      def add_options
        @site_or_resource = ARGV.shift
        
        if ARGV.first && !ARGV.first.starts_with?('-')
          @file = ARGV.shift
        end
        
        options.merge!(
          :page_ext       => 'haml',
          :javascript_ext => 'js',
          :stylesheet_ext => 'sass'
        )
        
        parser.on('--page', '--page-ext EXT', 'The extension used for generated Pages and Views') do |ext|
          options[:page_ext] = ext
        end
        
        parser.on('--js', '--javascript-ext EXT', 'The extension used for generated Javascripts') do |ext|
          options[:javascript_ext] = ext
        end
        
        parser.on('--css', '--stylesheet-ext EXT', 'The extension used for generated Stylesheets') do |ext|
          options[:stylesheet_ext] = ext
        end
      end
      
      def run
        if @file
          create_file File.join(site.config.path_for(@site_or_resource.pluralize), @file)
        else
          empty_directory @site_or_resource
          inside @site_or_resource do
            site.resources.each do |resource|
              empty_directory(resource.path)
            end
            create_file     File.join(Massimo::Page.path,       "index.#{options[:page_ext]}")
            create_file     File.join(Massimo::Javascript.path, "main.#{options[:javascript_ext]}")
            create_file     File.join(Massimo::Stylesheet.path, "main.#{options[:stylesheet_ext]}")
            create_file     File.join(Massimo::View.path,       "layouts/main.#{options[:page_ext]}")
            empty_directory site.config.output_path
          end
        end
      end
    end
  end
end