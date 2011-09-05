require "bundler"
Bundler.require :default, config.environment.to_sym

# This is an example configuration File
# Look here for all the available options:
# http://massimo.petebrowne.com/configuration/

if config.environment.production?
  # Compress javascripts and stylesheets
  config.compress = true
end

helpers do
  # Define helper methods here
end
