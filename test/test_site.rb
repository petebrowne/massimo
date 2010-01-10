require File.join(File.dirname(__FILE__), "helper")

class TestSite < Test::Unit::TestCase
  
  should "store configuration options" do
    @site = Massimo::Site(
      :source => source_dir,
      :output => output_dir
    )
    assert_equal source_dir, @site.options[:source]
    assert_equal output_dir, @site.options[:output]
  end
  
  should "use default options unless specified" do
    @site = Massimo::Site(:source => source_dir)
    assert_equal source_dir, @site.options[:source]
    assert_equal Massimo::Site::DEFAULT_OPTIONS[:output], @site.options[:output]
  end
  
  should "have refresh the configuration if new options are set" do
    Massimo::Site(:source => source_dir, :output => "/the/wrong/dir")
    @site = Massimo::Site(:source => source_dir)
    assert_equal Massimo::Site::DEFAULT_OPTIONS[:output], @site.options[:output]
  end
  
  should "have methods for determining the environment" do
    @site = Massimo::Site(:source => source_dir)
    assert @site.development?
    @site = Massimo::Site(:source => source_dir, :environment => :development)
    assert @site.development?
    @site = Massimo::Site(:source => source_dir, :environment => :production)
    assert @site.production?
  end
  
  context "Site#dir_for" do
    should "get the default path to directories" do
      @site = Massimo::Site(:source => source_dir)
      assert_equal source_dir("pages"), @site.dir_for(:pages)
    end
    
    should "get the specified path to directories from the options" do
      @site = Massimo::Site(:source => source_dir, :pages_path => source_dir("my_pages"))
      assert_equal source_dir("my_pages"), @site.dir_for(:pages)
    end
    
    should "get paths to files" do
      @site = Massimo::Site(:source => source_dir)
      assert_equal source_dir("random", "file.jpg"), @site.dir_for(:random, "file.jpg")
    end
  end
  
  context "Site#all_source_dirs" do
    should "get the directories of all the resources, libs, and helpers" do
      assert_equal [
        "./test/source/views",
        "./test/source/pages",
        "./test/source/stylesheets",
        "./test/source/javascripts",
        "./test/source/helpers",
        "./test/source/lib" ],
        site.all_source_dirs
    end
    
    should "include new resource directories" do
      class Post < Massimo::Page; end
      assert site.all_source_dirs.include?("./test/source/posts")
    end
    
    teardown do
      Massimo.resources.delete_if { |resource| resource.name == "post" }
    end
  end
  
  context "A Normal Site" do
    setup { site() }
  
    should "have a source_dir method" do
      assert_equal source_dir("some", "path"), @site.source_dir("some", "path")
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
    
end
