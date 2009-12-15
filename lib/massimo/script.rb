require "optparse"

module Massimo
  class Script
    attr_accessor :args, :options, :site, :source, :output
    
    #
    def initialize(args)
      # Parse the command line arguments
      self.args    = args
      self.options = {}
      self.parse!
      
      # Initialize the Site
      self.site    = Massimo::Site(self.options)
      self.options = self.site.options
      self.source  = self.options[:source]
      self.output  = self.options[:output]
    end
    
    # Run the script, based on the command line options.
    def run!
      if self.watch?
        self.watch_source!
      else
        self.process_site!
      end
      self.run_server! if self.server?
      return 0
    rescue Interrupt
      message "Massimo is done watching you.", :newline => true
      return 0
    rescue Exception => e
      message "Massimo Error: #{e.message}"
      puts e.backtrace
      return 1
    end
    
    protected
    
      # Watch the source for changes.
      def watch_source!
        require "directory_watcher"
      
        message %{Massimo is watching "#{source}" for changes. Press Ctrl-C to Stop.}
      
        watcher = DirectoryWatcher.new(source)
        watcher.interval = 1
        watcher.glob = Dir.chdir(source) do
          d  = Dir.glob("*").select { |x| File.directory?(x) }
          d -= [ File.basename(output) ]
          d  = d.map { |x| File.join(x, *%w{** *}) }
          d += [ "config.yml" ]
        end
      
        watcher.add_observer do |*args|
          time   = Time.now.strftime("%H:%M:%S %m/%d/%y")
          change = args.size == 1 ? "1 file" : "#{args.size} files"
          message "(#{time}) Massimo has rebuilt your site, #{change} changed."
          site.process!
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
      
      #
      def message(string, options = {})
        puts "\n" if options[:newline]
        puts "== #{string}"
      end
    
      # Determine if we should watch the source directory for changes.
      def watch?
        options[:watch] == true
      end
      
      # Determine if the server should be started.
      def server?
        options[:server] == true
      end
    
      # Parse the options
      def parse!
        opts = OptionParser.new do |opts|
          opts.banner = <<HELP
Massimo is a static website builder.

Basic Command Line Usage:
  massimo                                                   # . -> ./public
  massimo <path to write generated site>                    # . -> <path>
  massimo <path to source> <path to write generated site>   # <path> -> <path>

  Configuration is read from "<source>/config.yml" but can be overriden
  using the following options:

HELP
        
          opts.on("--watch", "Auto-regenerate the site as files are changed.") do
            options[:watch] = true
          end
        
          opts.on("--server", "Start web server with default port.") do |port|
            options[:server] = true
          end
          
          opts.on("--port [PORT]", "Select the port to start the web server on (defaults to 1984)") do |port|
            options[:server_port] = port
          end
        
          opts.on("--version", "Display current version") do
            puts "Massimo " + Massimo::VERSION
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
