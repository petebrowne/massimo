require 'active_support/core_ext/hash/keys'
require 'thor'

module Massimo
  class CLI < Thor
    include Thor::Actions
    
    source_root  File.expand_path('../templates', __FILE__)
    
    default_task :help
    
    class_option 'config_path', :desc => 'Path to the config file',              :aliases => '-c'
    class_option 'source_path', :desc => 'Path to the source dir',               :aliases => '-s'
    class_option 'output_path', :desc => 'Path to the output dir',               :aliases => '-o'
    class_option 'environment', :desc => 'Sets the environment',                 :aliases => '-e'
    class_option 'production',  :desc => "Sets the environment to 'production'", :aliases => '-p', :type => :boolean
    
    desc 'build', 'Builds the site from the source files'
    def build
      Kernel.exit Massimo::UI.report_errors {
        site.process
        Massimo::UI.say 'massimo has built your site', :growl => true
      }
    end
    map 'b' => :build
    
    desc 'new SITE_NAME', 'Generates a new site with the give name'
    def new(site_name)
      directory 'site', site_name
    end
    map %w(n generate g) => :new
    
    desc 'server [PORT]', 'Runs a local Rack based web server on the given port'
    def server(port = 3000)
      Massimo::Server.start(site, port.to_i)
    end
    map 's' => :server
    
    desc 'watch', 'Watches your files for changes and automatically builds the site'
    def watch
      Massimo::Watcher.start(site)
    end
    map 'w' => :watch
    
    desc 'version', 'Prints out the version'
    def version
      puts Massimo::VERSION
    end
    map %w(v -v --version) => :version
    
    protected
      
      def site
        @site ||= Massimo::Site.new(site_options)
      end
      
      def site_options
        config = {}.merge(options).symbolize_keys
        config[:environment] = 'production' if config.delete(:production) == true
        config
      end
  end
end
