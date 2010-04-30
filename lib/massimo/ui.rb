require 'active_support/core_ext/array/extract_options'

module Massimo
  module UI
    extend self
    
    COLOR_CODES = {
      :black   => 30,
      :red     => 31,
      :green   => 32,
      :yellow  => 33,
      :blue    => 34,
      :magenta => 35,
      :cyan    => 36
    }.freeze
    
    # Say (print) something to the user.
    def say(message, *args)
      options = args.extract_options!
      color   = args.first
      
      growl(message) if options[:growl]
      message = (' ' * padding) + message.to_s
      message = self.color(message, color) if color

      $stdout.puts(message)
    end
    
    # Color the given message with the given color
    def color(message, color)
      "\e[#{COLOR_CODES[color.to_sym]}m#{message}\e[0m"
    end
    
    # Run the given block and cleanly report any errors
    def report_errors
      begin
        yield
      rescue Exception => error
        say 'massimo had a problem', :red
        indent do
          say error.message, :magenta
          say error.backtrace.first, :magenta
        end
        growl "#{error.message}\n#{error.backtrace.first}", 'massimo problem'
      end
    end
    
    # Indents the messages within the block by the given amount.
    def indent(amount = 2)
      self.padding += amount
      yield
      self.padding -= amount
    end
    
    protected
    
      def growl(message, title = 'massimo')
        Growl.notify(message, :title => title) if defined?(Growl)
      end
    
      def padding
        @padding ||= 0
      end
      
      def padding=(value)
        @padding = [ 0, value.to_i ].max
      end
      
  end
end
