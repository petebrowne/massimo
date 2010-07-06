require 'active_support/core_ext/string/conversions'

module Massimo
  module Commands
    class Help < Base
      def add_options
        command_name = ARGV.shift
        unless command_name.nil? or %w( help version ).include?(command_name)
          @command = "Massimo::Commands::#{command_name.camelize}".constantize rescue nil
        end
      end
      
      def run
        if @command
          puts @command.new.parser
        else
          puts %{
#{Massimo::UI.color('massimo', :cyan)}
a static website builder

Commands:
  massimo build                             # Builds the site
  massimo generate SITE_OR_RESOURCE [FILE]  # Generates a new site
                                              Optionally generates a resource file
  massimo help [COMMAND]                    # Shows info about a specific command
  massimo server [PORT]                     # Runs a local web server
  massimo version                           # Displays current version
  massimo watch                             # Watches your files for changes
}
        end
      end
    end
    
  end
end
