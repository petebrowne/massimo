require 'active_support/inflector'
require 'tilt'

module Massimo
  class Site
    attr_accessor :config
    
    def initialize(options = nil)
      @config = Config.new(options)
      yield @config if block_given?
      Massimo.site = self
      
      @template_scope_blocks     = []
      @template_scope_extensions = []
    end
    
    def resources
      @resources ||= [ Massimo::Page, Massimo::Javascript, Massimo::Stylesheet, Massimo::View ]
    end
    
    def resource(name_or_class, &block)
      resource = case name_or_class
        when Class
          name_or_class
        else
          Object.const_set name_or_class.to_s.classify, Class.new(Massimo::Page, &block)
        end
      resources << resource
    end
    
    def template_scope
      @template_scope ||= begin
        scope = Object.new
        scope.extend(Massimo::Helpers, Tilt::CompileSite)
        @template_scope_blocks.each do |block|
          scope.instance_eval(&block)
        end
        @template_scope_extensions.each do |extension|
          scope.extend(extension)
        end
        scope
      end
    end
    
    def helpers(*extensions, &block)
      @template_scope_blocks     << block if block_given?
      @template_scope_extensions += extensions
    end
    
    def process
      reload_libs
      reload_helpers
      resources.select(&:processable?).each do |resource|
        resource.all.each(&:process)
      end
    end
    
    protected
    
      def reload_libs
        if defined? @previous_libs
          @previous_libs.each do |lib|
            class_name = class_name_of_file(lib)
            Object.class_eval do
              remove_const(class_name) if const_defined?(class_name)
            end
          end
        end
        @previous_libs = each_file_in(:lib) do |file|
          load(file)
        end
      end
      
      def reload_helpers
        @template_scope = nil
        each_file_in(:helpers) do |file|
          load(file)
          if helper = (class_name_of_file(file).constantize rescue nil)
            template_scope.extend(helper)
          end
        end
      end
      
      def each_file_in(dir, &block)
        Dir.glob(File.join(config.path_for(dir), '**/*.rb')).each do |file|
          yield file
        end
      end
      
      def class_name_of_file(file)
        File.basename(file).sub(/\.[^\.]+$/, '').classify
      end
  end
end
