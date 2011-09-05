require 'active_support/inflector'
require 'active_support/core_ext/string/conversions'
require 'tilt'

module Massimo
  class Site
    attr_accessor :config
    attr_reader   :resources
    
    # Creates a new Site, passing the given options to a new configuration.
    # If a block is given, it is evaluated in the scope of the new Site.
    def initialize(options = nil, &block)
      @original_options        ||= options
      @config                    = Config.new(options)
      @resources                 = [ Massimo::Page, Massimo::Javascript, Massimo::Stylesheet, Massimo::View ]
      @template_scope_blocks     = []
      @template_scope_extensions = []
      Massimo.site               = self
      
      Massimo::Reloader.reload(:config) do
        instance_eval File.read(config.config_path) if File.exist?(config.config_path)
        instance_eval(&block) if block_given?
      end
    end
    
    # Sets up the Site from scratch again. Also Reloads the config file again.
    def reload(&block)
      initialize @original_options, &block
    end
    
    # Adds a new, custom resource to the Site. If a Class constant is given,
    # it is added to directly to the `#resources`. If a Symbol or String is given, a new
    # Class (inheriting from Massimo::Page) is created using that name
    # with the given block used as the Class body.
    def resource(name_or_class, &block)
      resource = case name_or_class
        when Class
          name_or_class
        else
          Object.const_set name_or_class.to_s.classify, Class.new(Massimo::Page, &block)
        end
      resources << resource
    end
    
    # The scope used for templating. It includes helpers from Massimo::Helpers along
    # with any custom helpers.
    def template_scope
      Object.new.extend(Massimo::Helpers).tap do |scope|
        add_template_scope_blocks(scope)
        add_template_scope_extensions(scope)
        add_template_scope_helpers(scope)
      end
    end
    
    # Adds custom helpers to the `#template_scope`. Takes either an array of Modules
    # that will extend the scope, or a block of method definitions that will be added
    # to the scope.
    def helpers(*extensions, &block)
      @template_scope_blocks     << block if block_given?
      @template_scope_extensions += extensions
    end
    
    # Processes all the current resources.
    def process
      @template_scope = nil
      reload_libs
      resources.select(&:processable?).each do |resource|
        resource.all.each(&:process)
      end
    end
    
    protected
    
      def add_template_scope_blocks(scope)
        @template_scope_blocks.each do |block|
          scope.instance_eval(&block)
        end
      end
    
      def add_template_scope_extensions(scope)
        @template_scope_extensions.each do |extension|
          scope.extend(extension) if extension.instance_of?(Module)
        end
      end
    
      def add_template_scope_helpers(scope)
        cache = Massimo::Reloader.reload(:helpers) do
          config.files_in(:helpers, :rb).each do |file|
            load(file)
          end
        end
        
        if constants = cache[:constants]
          constants.each do |const|
            helper = const.to_s.constantize rescue nil
            scope.extend(helper) if helper.instance_of?(Module)
          end
        end
      end
  
      def reload_libs
        Massimo::Reloader.reload(:libs) do
          config.files_in(:lib, :rb).each do |file|
            load(file)
          end
        end
      end
  end
end