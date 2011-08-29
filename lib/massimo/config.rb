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
    
    # Sets up Massimo to compress both JavaScript and CSS files.
    #
    # @param [Boolean] compress Wether or not to compress.
    def compress=(compress)
      Crush.register if compress
    end
    
    # Sets up Massimo to compress JavaScript files. By default,
    # whichever JavaScript compression library is available, is used.
    # To set the one you want to use see #js_compressor=.
    #
    # @param [Boolean] compress Wether or not to compress.
    def compress_js=(compress)
      Crush.register_js if compress
    end
    
    # Sets the JavaScript compressor to use. The compressor can
    # be either a symbol mapping to the recognized Crush::Engines
    # (see JS_COMPRESSORS) or any Tilt::Template.
    #
    # @param [Tilt::Template, Symbol] compressor The compressor to use.
    def js_compressor=(compressor)
      if compressor.respond_to?(:to_sym)
        compressor = JS_COMPRESSORS[compressor.to_sym]
      end
      Tilt.prefer compressor, 'js'
    end
    
    # Sets the options used by the JavaScript compressor.
    #
    # @param [Hash] options The hash of options to use.
    def js_compressor_options=(options)
      self.js = options
    end
    
    # Sets up Massimo to compress CSS files. By default,
    # whichever CSS compression library is available, is used.
    # To set the one you want to use see #css_compressor=.
    #
    # @param [Boolean] compress Wether or not to compress.
    def compress_css=(compress)
      Crush.register_css if compress
    end
    
    # Sets the CSS compressor to use. The compressor can
    # be either a symbol mapping to the recognized Crush::Engines
    # (see CSS_COMPRESSORS) or any Tilt::Template.
    #
    # @param [Tilt::Template, Symbol] compressor The compressor to use.
    def css_compressor=(compressor)
      if compressor.respond_to?(:to_sym)
        compressor = CSS_COMPRESSORS[compressor.to_sym]
      end
      Tilt.prefer compressor, 'css'
    end
    
    # Sets the options used by the CSS compressor.
    #
    # @param [Hash] options The hash of options to use.
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