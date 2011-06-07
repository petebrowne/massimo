require 'sass'
require 'sprockets'

# This is an example configuration File
# Look here for all the available options:
# http://massimo.petebrowne.com/configuration/

if config.environment.production?
  # Use Uglifier for javascript compression
  # config.js_compressor = :uglifier
end

helpers do
  # Define helper methods here
end
