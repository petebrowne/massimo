require 'thor'

module Massimo
  class CLI < Thor
    include Thor::Actions
    
    default_task :build
    class_option 'config',      :desc => 'Path to the config file', :aliases => '-c'
    class_option 'source_path', :desc => 'Path to the source dir',  :aliases => '-s'
    class_option 'output_path', :desc => 'Path to the output dir',  :aliases => '-o'
    
    desc 'build', 'Builds the site'
    def build
      Massimo::UI.report_errors do
        site.process
        Massimo::UI.massimo 'has built your site'
      end
    end
    map 'b' => :build
    
    desc 'watch', 'Watches your files for changes and rebuilds'
    def watch
      Massimo::UI.massimo 'is watching your files for changes'
      Massimo::Watcher.start(site)
    end
    map 'w' => :watch
    
    desc 'server [PORT]', 'Runs a local web server and processes the site on save'
    def server(port = 3000)
      Massimo::UI.massimo "is serving your site at http://localhost:#{port}"
      Massimo::Server.start(site, port.to_i)
    end
    map 's' => :server
    
    desc 'generate SITE_OR_RESOURCE [FILE]', 'Generates a new site. Optionally generates a resource file.'
    method_option 'page_ext',
      :desc    => 'The extension used for generated Pages and Views',
      :default => 'haml',
      :aliases => '--page'
    method_option 'javascript_ext',
      :desc    => 'The extension used for generated Javascripts',
      :default => 'js',
      :aliases => '--js'
    method_option 'stylesheet_ext',
      :desc    => 'The extension used for generated Stylesheets',
      :default => 'sass',
      :aliases => '--css'
    def generate(site_or_resource, file = nil)
      require 'active_support/inflector'
      
      if file
        create_file File.join(site.config.path_for(site_or_resource.pluralize), file)
      else
        empty_directory site_or_resource
        inside site_or_resource do
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
    map 'g' => :generate
    
    desc 'version', 'Displays current version'
    def version
      Massimo::UI.say Massimo::VERSION
    end
    map %w( -v --version ) => :version
    
    protected
    
      def site
        @site ||= begin
          site = Massimo::Site.new config_file(:yml)
          if config_rb = config_file(:rb)
            site.instance_eval File.read(config_rb)
          end
          site.config.source_path = options[:source_path] if options[:source_path]
          site.config.output_path = options[:output_path] if options[:output_path]
          site
        end
      end
      
      def config_file(ext)
        if options[:config] && File.extname(options[:config]) == ".#{ext}"
          options[:config]
        elsif File.exist?("config.#{ext}")
          "config.#{ext}"
        end
      end
  end
end
