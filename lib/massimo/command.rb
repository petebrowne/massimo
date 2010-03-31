require "active_support/backtrace_cleaner"
require "active_support/core_ext/hash/keys"
begin require "growl"; rescue LoadError; end
require "optparse"
require "yaml"

module Massimo
  class Command
    attr_accessor :args, :options, :site, :source, :output
    
    # Default options. Overriden by values in config.yml or command-line opts.
    DEFAULT_OPTIONS = {
      :config_path => File.join(".", "config.yml")
    }.freeze
    
    #
    def initialize(args)
      # Parse the command line arguments
      self.args    = args
      self.options = DEFAULT_OPTIONS.dup
      self.parse!
      
      # Load the options from the config file
      config = YAML.load_file(self.options[:config_path]) if File.exist?(self.options[:config_path])
      self.options.merge!(config.symbolize_keys) if config.is_a?(Hash)
      
      # Initialize the Site
      self.site    = Massimo::Site(self.options)
      self.options = self.site.options
      self.source  = self.options[:source]
      self.output  = self.options[:output]
      
      # Setup Backtrace Cleaner
      @cleaner = ActiveSupport::BacktraceCleaner.new
      @cleaner.add_silencer { |line| line =~ /^(\/|\\)/ } # Remove full File path traces
    end
    
    # Run the script, based on the command line options.
    def run!
      if generate?
        generate_layout!
      elsif watch?
        watch_source!
      else
        process_site!
      end
      run_server! if server?
      return 0
    rescue Interrupt
      message "Massimo is done watching you.", :newline => true
      return 0
    rescue Exception => e
      report_error(e)
      return 1
    end
    
    protected
      
      # Generate the default layout of the site.
      def generate_layout!
        require "fileutils"
        message "Massimo is generating the default site layout"
        [ site.source_dir, site.all_source_dirs, site.output_dir ].flatten.each do |dir|
          full_dir = File.expand_path(dir)
          if File.exists?(full_dir)
            puts indent_body("exists: #{full_dir}")
          else
            FileUtils.mkdir_p(full_dir)
            puts indent_body("created: #{full_dir}")
          end
        end
      end
    
      # Watch the source for changes.
      def watch_source!
        require "directory_watcher"
      
        message %{Massimo is watching "#{source}" for changes. Press Ctrl-C to Stop.}
      
        watcher = DirectoryWatcher.new(
          ".",
          :interval => 1,
          :glob     => site.all_source_dirs.collect { |dir| File.join(dir, "**/*") }
        )
      
        watcher.add_observer do |*args|
          begin
            site.process!
            time   = Time.now.strftime("%l:%M:%S").strip
            change = args.size == 1 ? "1 file" : "#{args.size} files"
            message "Massimo has rebuilt your site. #{change} changed. (#{time})"
          rescue Exception => e
            report_error(e)
          end
        end
        
        watcher.start
        
        unless server?
          loop { sleep 1000 }
        end
      end
    
      # Process the site.
      def process_site!
        site.process!
        message %{Massimo has built your site in "#{site.options[:output]}"}
      end
    
      #
      def run_server!
        require "webrick"
        
        # Make sure the output dir exists
        FileUtils.mkdir_p(output)
        
        server = WEBrick::HTTPServer.new(
          :Port         => options[:server_port],
          :DocumentRoot => output
        )
        
        trap(:INT) do
          server.shutdown
          message "Massimo is shutting down the server.", :newline => true
          return 0
        end
        
        server.start
        message "Massimo is serving up your site at http://localhost:#{options[:server_port]}/"
      end
    
      # Determine if we should watch the source directory for changes.
      def watch?
        options[:watch] == true
      end
      
      # Determine if we should generate the default layout of the site.
      def generate?
        options[:generate] == true
      end
      
      # Determine if the server should be started.
      def server?
        options[:server] == true
      end
      
      #
      def message(string, options = {})
        options.reverse_merge!(:growl => true)
        puts "\n" if options[:newline]
        puts "== #{string}"
        Growl.notify(string, :title => "Massimo") if options[:growl] && defined?(Growl)
      end
      
      # Report the given error. This could eventually log the backtrace.
      def report_error(error = nil)
        error ||= $!
        
        # Show full backtrace if verbose
        backtrace = if options[:verbose]
          error.backtrace
        else
          @cleaner.clean(error.backtrace)
        end
        
        # show the message
        message "Massimo Error:", :newline => true, :growl => false
        puts indent_body(error.message)
        puts indent_body(backtrace)
        puts "\n"
        
        # Format the message differently for growl
        Growl.notify(error.message, :title => "Massimo Error") if defined?(Growl)
      end
      
      # Returns the string with each line indented.
      def indent_body(string)
        string.collect { |line| "  #{line}" }
      end
    
      # Parse the options
      def parse!
        opts = OptionParser.new do |opts|
          opts.banner = <<-HELP
Massimo is a static website builder.

Basic Command Line Usage:
  massimo                                   # . -> ./public
  massimo <path to output>                  # . -> <path>
  massimo <path to source> <path to output> # <path> -> <path>

  Configuration is read from "./config.yml" but can be overriden
  using the following options:

HELP
        
          opts.on("--config [PATH]", "The path to the config file.") do |path|
            options[:config_path] = path
          end
        
          opts.on("--generate", "Generate the default layout of the site. This will create all the necessary directories needed to generate websites using Massimo.") do
            options[:generate] = true
          end
        
          opts.on("--watch", "Auto-regenerate the site as files are changed.") do
            options[:watch] = true
          end
        
          opts.on("--server", "Start web server with default port.") do |port|
            options[:server] = true
          end
          
          opts.on("--port [PORT]", "Select the port to start the web server on. Defaults to 1984") do |port|
            options[:server_port] = port
          end
        
          opts.on("--verbose", "-V", "Show full backtrace on errors. Defaults to false.") do
            options[:verbose] = true
          end
        
          opts.on("--version", "-v", "Display current version") do
            puts "Massimo #{Massimo::VERSION}"
            exit 0
          end
        end
        opts.parse!

        # Get source and destintation from command line
        case args.size
        when 0
        when 1
          options[:source] = args[0]
        when 2
          options[:source] = args[0]
          options[:output] = args[1]
        else
          puts %{Invalid options. Run "massimo --help" for assistance.}
          exit 1
        end
      end
    
  end
end
