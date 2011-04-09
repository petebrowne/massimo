require 'sass'
require 'sprockets'

# This is an example configuration File
# Look here for all the available options:
# http://massimo.petebrowne.com/configuration/

if config.environment.production?
  # Use JSMin for javascript compression
  # config.javascripts_compressor = :min
  
  # Compress the output of Sass stylesheets
  # config.sass = { :style => :compressed }
end

helpers do
  # Define helper methods here
end
