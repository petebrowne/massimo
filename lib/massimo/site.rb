module Massimo
  class Site
    include Singleton
    
    # Default options. Overriden by values given when creating a Site.
    DEFAULT_OPTIONS = {
      :source      => ".",
      :output      => ::File.join(".", "public"),
      :server_port => "1984"
    }.freeze
    
    SOURCE_DIRS = [ :pages, :views, :stylesheets, :javascripts, :helpers, :lib ].freeze # :nodoc:
    
    attr_accessor :options, :helpers
    
    # Setup the Site with the given options. These options may be overridden by the config file.
    def setup(options = {})
      @options = DEFAULT_OPTIONS.dup.merge(options.symbolize_keys)
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
      page_paths = find_files_in(:pages)
      @pages = page_paths.collect { |path| ::Massimo::Page.new(path) }
    end
    
    # Get all the Stylesheets in the stylesheets dir.
    def stylesheets(reload = false)
      return @stylesheets if defined?(@stylesheets) && !reload
      stylesheet_paths = find_files_in(:stylesheets, [ :css, :sass, :less ])
      @stylesheets = stylesheet_paths.collect { |path| ::Massimo::Stylesheet.new(path) }
    end
    
    # Get all the Javascripts in the javascripts dir.
    def javascripts(reload = false)
      return @javascripts if defined?(@javascripts) && !reload
      javascript_paths = find_files_in(:javascripts, [ :js ])
      @javascripts = javascript_paths.collect { |path| ::Massimo::Javascript.new(path) }
    end
    
    # Finds a view by the given name
    def find_view(name, meta_data = {})
      view_path = Dir.glob(dir_for(:views, "#{name}.*")).first
      view_path && ::Massimo::View.new(view_path, meta_data)
    end
    
    # Finds a view then renders it with the given locals
    def render_view(name, locals = {}, &block)
      view = find_view(name)
      view && view.render(locals, &block)
    end
    
    # Determines if the Site is in development mode.
    def development?
      @options[:environment].nil? || @options[:environment].to_sym == :development || @options[:development]
    end
    
    # Determines if the Site is in production mode.
    def production?
      (@options[:environment] && @options[:environment].to_sym == :production) || @options[:production]
    end
    
    #------------------------------------
    #  Directory Path Methods
    #------------------------------------
    
    # The path to the source dir
    def source_dir(*path)
      ::File.join(@options[:source], *path)
    end
    
    # Get all the source directories as an array.
    def all_source_dirs
      SOURCE_DIRS.collect { |d| dir_for(d) }
    end
    
    SOURCE_DIRS.each do |d|
      define_method("#{d}_dir") do |*path|
        dir_for(d, *path)
      end
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
          source_dir(type.to_s, *path)
        end
      end
    
      # Find all the files in the given resouce type's directory, optionally
      # selecting only those with the given extensions. This will return
      # an array with the full path to the files.
      def find_files_in(type, extensions = nil)
        # the directory where these files will be found
        type_dir = dir_for(type)
        
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
              when ::Proc
                skip_files.call(file)
              else
                false
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
        @helpers = ::Massimo::Helpers.new(helper_modules.compact)
      end
      
      # Reload all the files in the source lib dir.
      def reload_libs
        reload_files ::Dir.glob(dir_for(:lib, "**", "*.rb"))
      end
      
      # Find all the helper modules
      def helper_modules
        reload_files ::Dir.glob(dir_for(:helpers, "*.rb"))
      end
      
      # Relod the given file by removing their constants and loading the file again.
      # Return an Array of the reloaded Constants.
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
