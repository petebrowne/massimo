module Massimo
  class Site
    include Singleton
    
    # Default options. Overriden by values given when creating a Site.
    DEFAULT_OPTIONS = {
      :source      => ".",
      :output      => File.join(".", "public"),
      :server_port => "1984"
    }.freeze
    
    attr_accessor :options, :helpers
    
    # Setup the Site with the given options. These options may be overridden by the config file.
    def setup(options = {})
      @options = DEFAULT_OPTIONS.dup.merge(options.symbolize_keys)
      reload
      self
    end
    
    # Reload helpers and libs.
    def reload
      reload_helpers
      reload_libs
      reload_resources
    end
    
    # Processes all the Pages, Stylesheets, and Javascripts and outputs
    # them to the output dir.
    def process!
      reload
      Massimo.processable_resources.each(&:process!)
    end
    
    # Finds a view by the given name
    def find_view(name, meta_data = {})
      view_path = Dir.glob(dir_for(:views, "#{name}.*")).first
      view_path && Massimo::View.new(view_path, meta_data)
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
      File.join(@options[:source], *path)
    end
    
    # Get the directory to the given resource type (pages, views, etc.).
    # If the path has been manually set in the options, you will get that
    # path. Otherwise you will get the path relative to the source directory.
    def dir_for(type, *path)
      if type_path = @options["#{type}_path".to_sym]
        File.join(type_path, *path)
      else
        source_dir(type.to_s, *path)
      end
    end
    
    # Get all the source directories as an array.
    def all_source_dirs
      Massimo.resources.collect(&:dir) + [ dir_for(:helpers), dir_for(:lib) ]
    end
    
    # The path to the output dir
    def output_dir(*path)
      File.join(@options[:output], *path)
    end
    
    protected
      
      # Reload the Helpers instance with the helper modules
      def reload_helpers
        @helpers = Helpers.new(helper_modules.compact)
      end
      
      # Reload all the files in the source lib dir.
      def reload_libs
        reload_files Dir.glob(dir_for(:lib, "**", "*.rb"))
      end
    
      # Load methods for listing all available files for each Resource type.
      def reload_resources
        class_eval do
          # Define methods for getting all of the files for each Resource Type
          Massimo.processable_resources.each do |type|
            define_method(type.name.to_s.pluralize) do |*args|
              type.all(*args)
            end
          end
        end
      end
      
      # Find all the helper modules
      def helper_modules
        reload_files Dir.glob(dir_for(:helpers, "*.rb"))
      end
      
      # Relod the given file by removing their constants and loading the file again.
      # Return an Array of the reloaded Constants.
      def reload_files(files)
        files.collect do |file|
          load(file)
          class_name = File.basename(file).gsub(File.extname(file), "").classify
          class_name.constantize rescue nil
        end
      end
  end
end
