require File.join(File.dirname(__FILE__), "helper")

class TestSite < Test::Unit::TestCase
  
  def source_page_paths
    @source_page_paths ||= Pathname.glob(source_dir("pages", "**", "*")).
      reject  { |p| p.basename.to_s =~ /^_/ || File.directory?(p) }.
      collect { |p| p.basename }
  end
  
  should "store configuration options" do
    @site = Massimo::Site(
      :source  => "./source",
      :output  => "./output"
    )
    assert_equal "./source", @site.options[:source]
    assert_equal "./output", @site.options[:output]
  end
  
  should "use default options unless specified" do
    @site = Massimo::Site(:output => "./output")
    assert_equal Massimo::Site::DEFAULT_OPTIONS[:source], @site.options[:source]
    assert_equal "./output", @site.options[:output]
  end
  
  should "have refresh the configuration if new options are set" do
    Massimo::Site(:souce => "/some/strange/dir", :output => "/the/wrong/dir")
    @site = Massimo::Site(:output => "/the/wrong/dir")
    assert_equal Massimo::Site::DEFAULT_OPTIONS[:source], @site.options[:source]
  end
  
  should "have methods for determining the environment" do
    @site = Massimo::Site()
    assert @site.development?
    @site = Massimo::Site(:environment => :development)
    assert @site.development?
    @site = Massimo::Site(:environment => :production)
    assert @site.production?
  end
  
  context "A Normal Site" do
    setup { site() }
  
    should "have a source_dir method" do
      assert_equal source_dir("some", "path"), @site.source_dir("some", "path")
    end
  
    should "have a directory shortcut methods" do
      assert_equal source_dir("pages", "some", "file.txt"),       @site.pages_dir("some", "file.txt")
      assert_equal source_dir("views", "some", "file.txt"),       @site.views_dir("some", "file.txt")
      assert_equal source_dir("stylesheets", "some", "file.txt"), @site.stylesheets_dir("some", "file.txt")
      assert_equal source_dir("javascripts", "some", "file.txt"), @site.javascripts_dir("some", "file.txt")
    end
  
    should "have a output_dir method" do
      assert_equal output_dir("some", "path"), @site.output_dir("some", "path")
    end
  
    should "render a view by name" do
      assert_equal "<h1>Title</h1>\n", @site.render_view("with_locals", :title => "Title")
    end
  
    should "find all the pages in the pages dir" do
      page_paths = @site.pages.collect { |page| page.source_path.basename }
      assert_equal_arrays source_page_paths, page_paths
    end
  
    should "add helpers from the helpers directory" do
      assert_equal "<p>working</p>\n", @site.render_view("with_helper")
    end
    
    should "require the lib directory for further customization" do
      assert_equal "working", @site.new_method
    end
  
    context "processing Sites" do
      setup { @site.process! }
      
      should "process each page in the pages dir" do
        output_page_paths = Dir.glob(output_dir("**", "*.{html,rss}"))
        assert_equal source_page_paths.length, output_page_paths.length
      end
    
      should "process each stylesheet file in the stylesheets dir" do
        assert File.exist?(output_dir("stylesheets", "application.css"))
        assert File.exist?(output_dir("stylesheets", "less_file.css"))
        assert File.exist?(output_dir("stylesheets", "basic.css"))
      end
    
      should "process each javascript file in the javascripts dir" do
        assert File.exist?(output_dir("javascripts", "application.js"))
        assert File.exist?(output_dir("javascripts", "lib.js"))
      end
    
      teardown { clear_output }
    end
  end
  
  should "find only the pages set in the :pages option" do
    only_pages = %w{about_us.erb feed.haml index.erb}
    page_paths = Massimo::Site(:source => source_dir, :pages => only_pages).pages(true).collect { |page| page.source_path.basename }
    assert_equal_arrays only_pages, page_paths
  end

  should "skip pages set in the :skip_pages option (as an Array)" do
    skip_pages = %w{about_us.erb erb.erb erb_with_layout.erb feed.haml posts/first-post.haml haml.haml html.html index.erb markdown.markdown}
    page_paths = Massimo::Site(:source => source_dir, :skip_pages => skip_pages).pages(true).collect { |page| page.source_path.basename }
    assert_equal_arrays [
      "with_extension.haml",
      "with_meta_data.haml",
      "with_title.haml",
      "with_url.haml",
      "without_extension.haml",
      "without_meta_data.haml",
      "without_title.haml",
      "without_url.haml"
    ], page_paths
  end

  should "skip pages set in the :skip_pages option (as a Proc)" do
    site_options = { :source => source_dir, :skip_pages => lambda { |file| file.include?("with") } }
    page_paths = Massimo::Site(site_options).pages(true).collect { |page| page.source_path.basename }
    assert_equal_arrays %w{about_us.erb erb.erb feed.haml first-post.haml haml.haml html.html index.erb markdown.markdown}, page_paths
  end
    
end
