$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rubygems"
require "test/unit"
require "shoulda"
# begin require "redgreen"; rescue LoadError; end
begin require "turn"; rescue LoadError; end
require "assertions"
require "rr"

# Load Massimo
require File.join(File.dirname(__FILE__), "..", "lib", "massimo")

class Test::Unit::TestCase
  include Assertions
  include RR::Adapters::TestUnit

  #
  def source_dir(*subdirs)
    File.join(File.dirname(__FILE__), "source", *subdirs)
  end

  #
  def output_dir(*subdirs)
    File.join(File.dirname(__FILE__), "output", *subdirs)
  end

  #
  def clear_output
    FileUtils.rm_rf(output_dir)
  end
  
  #
  def site(options = {})
    @site = ::Massimo::Site({
      :source => source_dir,
      :output => output_dir,
      :sass   => { :cache => false }
    }.merge(options))
  end
  
  #
  def page(*path)
    @page ||= ::Massimo::Page.new(source_dir("pages", *path))
  end
  
  #
  def view(*path)
    return @view if defined?(@view)
    meta_data = path.extract_options!
    @view = ::Massimo::View.new(source_dir("views", *path), meta_data)
  end
end
