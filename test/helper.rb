testdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)

libdir = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "rubygems"
require "massimo"
require "test/unit"
require "assertions"
require "shoulda"
require "rr"

begin
  require "turn"
rescue LoadError
  begin require "redgreen"; rescue LoadError; end
end

class Test::Unit::TestCase
  include Assertions
  include RR::Adapters::TestUnit

  def source_dir(*subdirs)
    File.join("./test/source", *subdirs)
  end

  def output_dir(*subdirs)
    File.join("./test/output", *subdirs)
  end

  # Clears all the output files created during tests.
  def clear_output
    FileUtils.rm_rf(output_dir)
  end
  
  # Create a new Site instance
  def site(options = {})
    @site = ::Massimo::Site({
      :source => source_dir,
      :output => output_dir,
      :sass   => { :cache => false }
    }.merge(options))
  end
  
  # Creates a Page instance for the given path
  def page(*path)
    @page ||= ::Massimo::Page.new(source_dir("pages", *path))
  end
  
  # Creates a View Instance for the given path
  def view(*path)
    return @view if defined?(@view)
    meta_data = path.extract_options!
    @view = ::Massimo::View.new(source_dir("views", *path), meta_data)
  end
  
  # All the Page paths in the source dir
  def source_page_paths
    @source_page_paths ||= Pathname.glob(source_dir("pages/**/*")).
      reject  { |p| p.basename.to_s =~ /^_/ || File.directory?(p) }.
      collect { |p| p.basename }
  end
end
