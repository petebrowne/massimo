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
    def say(message, color = nil)
      message = (' ' * padding) + message.to_s
      message = self.color(message, color) if color

      $stdout.puts(message)
    end
    
    #
    def massimo(message, color = nil)
      say bold('massimo ') + message, color
    end
    
    # Bolden the given message
    def bold(message)
      ansify(message, 1, 22)
    end
    
    # Color the given message with the given color
    def color(message, color)
      ansify(message, COLOR_CODES[color.to_sym])
    end
    
    # Run the given block and cleanly report any errors
    def report_errors
      begin
        yield
      rescue Exception => error
        massimo 'had a problem', :red
        indent do
          say error.message, :magenta
          error.backtrace.each { |line| say line }
          say ''
        end
      end
    end
    
    # Indents the messages within the block by the given amount.
    def indent(amount = 2)
      self.padding += amount
      yield
      self.padding -= amount
    end
    
    protected
    
      def ansify(message, open, close = 0)
        "\e[#{open}m#{message}\e[#{close}m"
      end
    
      def padding
        @padding ||= 2
      end
      
      def padding=(value)
        @padding = [ 0, value.to_i ].max
      end
      
  end
end
