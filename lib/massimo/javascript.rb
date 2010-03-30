require "jsmin"
require "sprockets"
require "massimo/resource/base"

module Massimo
  class Javascript < Massimo::Resource::Base
    processable!
    
    # Concat the Javascript using Sprockets, then minify using JSmin
    def render
      secretary = Sprockets::Secretary.new(
        :assert_root  => site.output_dir,
        :source_files => [ @source_path.to_s ]
      )
      # install assets if necessary
      secretary.install_assets
      
      # Concatenate the scripts and minify if necessary
      output = secretary.concatenation.to_s
      output = JSMin.minify(output) if site.production? or site.options[:minify]
      output
    end
  end
end
