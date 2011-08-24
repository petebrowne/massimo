require 'active_support/core_ext/hash/keys'
require 'active_support/string_inquirer'
require 'crush'
require 'ostruct'
require 'tilt'
require 'yaml'

module Massimo
  class Config < OpenStruct
    DEFAULT_OPTIONS = {
      :config_path     => 'config.rb',
      :source_path     => '.',
      :output_path     => 'public',
      :environment     => 'development',
      :resources_path  => '.',
      :base_url        => '/',
      :resources_url   => '/',
      :javascripts_url => '/javascripts',
      :stylesheets_url => '/stylesheets'
    }.freeze
    
    JS_COMPRESSORS = {
      :jsmin    => Crush::JSMin,
      :packr    => Crush::Packr,
      :yui      => Crush::YUI::JavaScriptCompressor,
      :closure  => Crush::Closure::Compiler,
      :uglifier => Crush::Uglifier
    }
    
    CSS_COMPRESSORS = {
      :cssmin    => Crush::CSSMin,
      :rainpress => Crush::Rainpress,
      :yui       => Crush::YUI::CssCompressor
    }
    
    # Creates a new configuration. Takes either a hash of options
    # or a file path to a .yaml file.
    def initialize(options = nil)
      hash = DEFAULT_OPTIONS.dup
      hash.merge!(options.symbolize_keys) if options.is_a? Hash
      super hash
    end
    
    # The full, expanded path to the config file
    def config_path
      File.expand_path super
    end
    
    # The full, expanded path to the source directory.
    def source_path
      File.expand_path super
    end
    
    # The full, expanded path to the output directory.
    def output_path
      File.expand_path super
    end
    
    # Return the enviornment option wrapped by a StringInquirer, so you can
    # query the environment like this: `config.environment.production?`
    def environment
      ActiveSupport::StringInquirer.new(super)
    end
    
    # Sets the javascript compression engine by name, using Crush,
    # and sets #compress_js to true.
    def js_compressor=(compressor)
      if compressor.respond_to?(:to_sym)
        compressor = JS_COMPRESSORS[compressor.to_sym]
      end
      Tilt.register(compressor, 'js')
    end
    
    #
    def js_compressor_options=(options)
      self.js = options
    end
    
    # Sets the stylesheet compression engine by name, using Crush,
    # and sets #compress_css to true.
    def css_compressor=(compressor)
      if compressor.respond_to?(:to_sym)
        compressor = CSS_COMPRESSORS[compressor.to_sym]
      end
      Tilt.register(compressor, 'css')
    end
    
    #
    def css_compressor_options=(options)
      self.css = options
    end
    
    # Get a full, expanded path for the given resource name. This is either set
    # in the configuration or determined dynamically based on the name.
    def path_for(resource_name)
      if resource_path = send("#{resource_name}_path")
        File.expand_path resource_path
      else
        File.join source_path, resource_name.to_s
      end
    end
    
    # Get the configured URL for th given resource name.
    def url_for(resource_name)
      File.join base_url, send("#{resource_name}_url") || resources_url
    end
    
    # Get an array of all the file paths found in the given resource name's path,
    # restricted to the given extension.
    def files_in(resource_name, extension = '*')
      Dir.glob File.join(path_for(resource_name), "**/*.#{extension}")
    end
    
    # Convience method for getting options for a given library name. For instance,
    # this is how we get the options set for Haml or Sass during processing.
    def options_for(lib_name)
      return options_for("sass") if lib_name == "scss"
      send(lib_name) || {}
    end
  end
end