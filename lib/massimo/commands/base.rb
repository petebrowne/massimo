require 'optparse'
require 'thor/actions'
require 'thor/shell'

module Massimo
  module Commands
    class Base
      include Thor::Actions
      include Thor::Shell
      
      attr_reader :options, :parser
      
      def self.run
        command = self.new
        command.parse
        command.run
      end
      
      def initialize
        @options = {}
        @parser  = OptionParser.new
        
        parser.banner = "#{banner}\n" if respond_to?(:banner)
        common_options
        add_options if respond_to?(:add_options)
        
        # needed for Thor::Actions to work
        self.destination_root = nil
      end
      
      def common_options
        parser.on('-c', '--config FILE', 'Path to the config file') do |config|
          options[:config] = config
        end
        
        parser.on('-s', '--source-path PATH', 'Path to the source dir') do |path|
          options[:source_path] = path
        end
        
        parser.on('-o', '--output-path PATH', 'Path to the output dir') do |path|
          options[:output_path] = path
        end
        
        parser.on('-e', '--environment ENV', 'Sets the Site environment') do |env|
          options[:environment] = env
        end
        
        parser.on('-p', '--production', "Sets the Site environment to 'production'") do |production|
          options[:environment] = 'production'
        end
      end
      
      def parse
        begin
          parser.parse(ARGV)
        rescue
          say parser
          exit
        end
      end
      
      def run
      end
      
      def site
        @site ||= Massimo::Site.new(config_file(:yml)).tap do |site|
          site.config.environment = options[:environment] if options[:environment]
          site.config.source_path = options[:source_path] if options[:source_path]
          site.config.output_path = options[:output_path] if options[:output_path]
          if config_rb = config_file(:rb)
            site.instance_eval File.read(config_rb)
          end
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
end