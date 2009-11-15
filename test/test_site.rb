require "helper"

class TestSite < Test::Unit::TestCase
  
  def source_page_paths
    @source_page_paths ||= Pathname.glob(source_dir("pages", "**", "*")).
      reject  { |p| p.to_s =~ /\.rtf$/ || p.basename.to_s =~ /^_/ }.
      collect { |p| p.basename }
  end
  
  should "store configuration options" do
    options = {
      :source => "./source",
      :output => "./output"
    }
    @site = Massimo::Site.new(options)
    assert_equal @site.options[:source], options[:source]
    assert_equal @site.options[:output], options[:output]
  end
  
  should "use default options unless specified" do
    options = { :output => "./output" }
    @site = Massimo::Site.new(options)
    assert_equal @site.options[:source], Massimo::Site::DEFAULT_OPTIONS[:source]
    assert_equal @site.options[:output], options[:output]
  end
  
  should "use options set in the config.yml file" do
    assert_equal site.options[:config], "working"
  end
  
  should "have a source_dir method" do
    assert_equal site.source_dir("some", "path"), source_dir("some", "path")
  end
  
  should "have a directory shortcut methods" do
    assert_equal site.pages_dir("some", "file.txt"),       source_dir("pages", "some", "file.txt")
    assert_equal site.views_dir("some", "file.txt"),       source_dir("views", "some", "file.txt")
    assert_equal site.stylesheets_dir("some", "file.txt"), source_dir("stylesheets", "some", "file.txt")
    assert_equal site.javascripts_dir("some", "file.txt"), source_dir("javascripts", "some", "file.txt")
  end
  
  should "have a output_dir method" do
    assert_equal site.output_dir("some", "path"), output_dir("some", "path")
  end
  
  should "render a view by name" do
    assert_equal site.render_view("with_locals", :title => "Title"), "<h1>Title</h1>\n"
  end
  
  should "find only the pages set in the :pages option" do
    only_pages = %w{about_us.erb feed.haml index.erb}
    page_paths = site(:pages => only_pages).pages.collect { |page| page.source_path.basename }
    assert_equal_arrays page_paths, only_pages
  end
  
  should "skip pages set in the :skip_pages option (as an Array)" do
    skip_pages = %w{about_us.erb feed.haml index.erb}
    page_paths = site(:skip_pages => skip_pages).pages.collect { |page| page.source_path.basename }
    assert_equal_arrays page_paths, [
      "with_extension.haml",
      "with_meta_data.haml",
      "with_title.haml",
      "with_url.haml",
      "without_extension.haml",
      "without_meta_data.haml",
      "without_title.haml",
      "without_url.haml"
    ]
  end
  
  should "skip pages set in the :skip_pages option (as a Proc)" do
    site_options = { :skip_pages => lambda { |file| file.include?("with") } }
    page_paths = site(site_options).pages.collect { |page| page.source_path.basename }
    assert_equal_arrays page_paths, %w{about_us.erb feed.haml index.erb}
  end
  
  should "find all the pages in the pages dir" do
    page_paths = site.pages.collect { |page| page.source_path.basename }
    assert_equal_arrays page_paths, source_page_paths
  end
  
  should "add helpers from the helpers directory" do
    assert_equal site.render_view("with_helper"), "<p>working</p>\n"
  end
  
  context "processing Sites" do
    
    should "process each page in the pages dir" do
      site.process!
      output_page_paths = Dir.glob(output_dir("**", "*.{html,rss}"))
      assert_equal source_page_paths.length, output_page_paths.length
    end
    
    should "process each stylesheet file in the stylesheets dir" do
      site.process!
      assert File.exist?(output_dir("stylesheets", "application.css"))
      assert File.exist?(output_dir("stylesheets", "less_file.css"))
      assert File.exist?(output_dir("stylesheets", "basic.css"))
    end
    
    should "process each javascript file in the javascripts dir" do
      site.process!
      assert File.exist?(output_dir("javascripts", "application.js"))
      assert File.exist?(output_dir("javascripts", "lib.js"))
    end
    
    teardown { clear_output }
    
  end
    
end
