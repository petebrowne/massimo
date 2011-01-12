require 'sass'
require 'sprockets'

# Example configuration
# http://petebrowne.github.com/massimo/configuration/
# config.output_path = 'output'

if config.environment.production?
  # Use JSMin for javascript compression
  # config.javascripts_compressor = :min
  
  # Compress the output of Sass stylesheets
  # config.sass = { :style => :compressed }
end

helpers do
  # Define helper methods here
end
