module Massimo
  class Site
    include Singleton
    
    # Default options. Overriden by values in config.yml or command-line opts.
    DEFAULT_OPTIONS = {
      :source      => ".",
      :output      => ::File.join(".", "public"),
      :server_port => "1984"
    }.freeze
    
    attr_accessor :options, :helpers
    
    # 
    def setup(options = {})
      options.symbolize_keys!
      @options = DEFAULT_OPTIONS.dup
      
      # get source from options
      @options[:source] = options[:source] if options[:source]
      
      # get options from config.yml file if it exists
      config_path = self.source_dir("config.yml")
      config = ::YAML.load_file(config_path) if ::File.exist?(config_path)
      @options.merge!(config.symbolize_keys) if config.is_a?(::Hash)
      
      @options.merge!(options)
      self
    end
    
    # Processes all the Pages, Stylesheets, and Javascripts and outputs
    # them to the output dir.
    def process!
      reload_helpers
      reload_libs
      pages(true).each(&:process!)
      stylesheets(true).each(&:process!)
      javascripts(true).each(&:process!)
    end
    
    # Get all the Pages in the pages dir.
    def pages(reload = false)
      return @pages if defined?(@pages) && !reload
      page_paths = self.find_files_in(:pages)
      @pages = page_paths.collect { |path| ::Massimo::Page.new(path) }
    end
    
    # Get all the Stylesheets in the stylesheets dir.
    def stylesheets(reload = false)
      return @stylesheets if defined?(@stylesheets) && !reload
      stylesheet_paths = self.find_files_in(:stylesheets, [ :css, :sass, :less ])
      @stylesheets = stylesheet_paths.collect { |path| ::Massimo::Stylesheet.new(path) }
    end
    
    # Get all the Javascripts in the javascripts dir.
    def javascripts(reload = false)
      return @javascripts if defined?(@javascripts) && !reload
      javascript_paths = self.find_files_in(:javascripts, [ :js ])
      @javascripts = javascript_paths.collect { |path| ::Massimo::Javascript.new(path) }
    end
    
    # Finds a view by the given name
    def find_view(name, meta_data = {})
      view_path = Dir.glob(self.views_dir("#{name}.*")).first
      view_path && ::Massimo::View.new(view_path, meta_data)
    end
    
    # Finds a view then renders it with the given locals
    def render_view(name, locals = {}, &block)
      view = self.find_view(name)
      view && view.render(locals, &block)
    end
    
    # The path to the source dir
    def source_dir(*path)
      ::File.join(@options[:source], *path)
    end
    
    # Get all the source directories as an array.
    def all_source_dirs
      [ :pages, :views, :stylesheets, :javascripts, :helpers, :lib ].collect { |p| dir_for(p) }
    end
    
    # The path to the pages directory.
    def pages_dir(*path)
      dir_for(:pages, *path)
    end
    
    # The path to the views directory.
    def views_dir(*path)
      dir_for(:views, *path)
    end
    
    # The path to the stylesheets directory.
    def stylesheets_dir(*path)
      dir_for(:stylesheets, *path)
    end
    
    # The path to the javascripts directory.
    def javascripts_dir(*path)
      dir_for(:javascripts, *path)
    end
    
    # The path to the helpers directory.
    def helpers_dir(*path)
      dir_for(:helpers, *path)
    end
    
    # The path to the lib directory.
    def lib_dir(*path)
      dir_for(:lib, *path)
    end
    
    # The path to the output dir
    def output_dir(*path)
      ::File.join(@options[:output], *path)
    end
    
    protected
    
      # Get the directory to the given resource type (pages, views, etc.).
      # If the path has been manually set in the options, you will get that
      # path. Otherwise you will get the path relative to the source directory.
      def dir_for(type, *path)
        if type_path = @options["#{type}_path".to_sym]
          ::File.join(type_path, *path)
        else
          self.source_dir(type.to_s, *path)
        end
      end
    
      # Find all the files in the given resouce type's directory, optionally
      # selecting only those with the given extensions. This will return
      # an array with the full path to the files.
      def find_files_in(type, extensions = nil)
        # the directory where these files will be found
        type_dir = self.dir_for(type)
        
        # By default get the file list from the options
        files = @options[type] && @options[type].dup
        
        unless files && files.is_a?(::Array)
          # If files aren't listed in the options, get them
          # from the given block
          glob  = (extensions.nil? || extensions.empty?) ? "*" : "*.{#{extensions.join(",")}}"
          files = ::Dir.glob(::File.join(type_dir, "**", glob))
          
          # normalize the files by removing the directory from the path
          files.collect! { |file| file.gsub("#{type_dir}/", "") }
          
          # reject the files in the skip_files option, which can
          # either be an array or a Proc.
          if skip_files = @options["skip_#{type}".to_sym]
            files.reject! do |file|
              case skip_files
              when ::Array
                skip_files.include?(file)
              else ::Proc
                skip_files.call(file)
              end
            end
          end
        end
        
        # Reject all files that begin with _ (like partials) and directories
        files.reject! { |file| ::File.basename(file) =~ /^_/ }
        
        # now add the directory back to the path
        files.collect! { |file| ::File.join(type_dir, file) }
        
        # And make sure we don't find directories
        files.reject! { |file| ::File.directory?(file) }
        files
      end
      
      # Reload the Helpers instance with the helper modules
      def reload_helpers
        @helpers = ::Massimo::Helpers.new(self.helper_modules.compact)
      end
      
      # Find all the helper modules
      def helper_modules
        reload_files ::Dir.glob(helpers_dir("*.rb"))
      end
      
      # Reload all the files in the source lib dir.
      def reload_libs
        reload_files ::Dir.glob(lib_dir("**", "*.rb"))
      end
      
      #
      def reload_files(files)
        files.collect do |file|
          class_name = ::File.basename(file).gsub(::File.extname(file), "").classify
          # Unload the constant if it already exists
          ::Object.class_eval { remove_const(class_name) if const_defined?(class_name) }
          # Load the constant
          load(file)
          # return the constant
          class_name.constantize rescue nil
        end
      end
  end
end
