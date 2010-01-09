require File.join(File.dirname(__FILE__), "helper")

class TestPage < Test::Unit::TestCase
  context "A Site" do
    setup { site() }
    
    
    context "Page without meta_data" do
      setup { page("without_meta_data.haml") }
    
      should "return a non-empty hash when calling meta_data" do
        assert_instance_of Hash, @page.meta_data
        assert !@page.meta_data.empty?
      end
    end
  
    context "Page with meta_data" do
      setup { page("with_meta_data.haml") }
    
      should "return a non-empty hash when calling meta_data" do
        assert_instance_of Hash, @page.meta_data
        assert !@page.meta_data.empty?
      end
    
      should "be able to access meta_data directly through methods on the Page" do
        assert_instance_of Array, @page.tags
      end
    
      should "be able to write new meta_data dynamically" do
        @page.new_tag = "test"
        assert_equal "test", @page.new_tag
      end
    end
  
    context "Page with title" do
      setup { page("with_title.haml") }
    
      should "fetch the title from the meta_data" do
        assert_equal "A Title", @page.title
      end
    end
  
    context "Page without title" do
      setup { page("without_title.haml") }
    
      should "create the title from the file name" do
        assert_equal "Without Title", @page.title
      end
    end
  
    context "Page with extension" do
      setup { page("with_extension.haml") }
    
      should "fetch the extension from the meta_data" do
        assert_equal ".rss", @page.extension
      end
    end
  
    context "Page without extension" do
      setup { page("without_extension.haml") }
    
      should "default to .html" do
        assert_equal ".html", @page.extension
      end
    end
  
    context "Page with URL" do
      setup { page("with_url.haml") }
    
      should "fetch the extension from the meta_data" do
        assert_equal "/page-with-url", @page.url
      end
    end
  
    context "Page without URL" do
      setup { page("without_url.haml") }
    
      should "default to .html" do
        assert_equal "/without-url", @page.url
      end
    end
    
    should "fetch the body from the page file" do
      assert_equal %{<h1>An <%= "HTML" %> Page</h1>}, page("about_us.erb").body
    end
  
    context "rendering Pages" do
      context "without layouts" do
      
        should "render erb content from the page file correctly" do
          assert_equal "<h1>ERB</h1>", page("erb.erb").render
        end
        
        should "render haml content from the page file correctly" do
          assert_equal "<h1>Haml</h1>\n", page("haml.haml").render
        end
        
        should "render markdown content from the page file correctly" do
          assert_equal "<h1>Markdown</h1>\n", page("markdown.markdown").render
        end
        
        should "render html content from the page file correctly" do
          assert_equal "<h1>HTML</h1>", page("html.html").render
        end
      
      end
      
      context "with layouts" do
      
        should "filter the content from the page file correctly" do
          assert_equal "<title>ERB With Layout</title>\n<body><h1>ERB With Layout</h1></body>\n", page("erb_with_layout.erb").render
        end
        
        should "render the page without a layout when calling #to_s" do
          page("erb_with_layout.erb")
          assert_equal @page.render(false), @page.to_s
        end
      end
    end
    
    context "processing Pages" do
    
      should "write the filtered body to a new file in the output dir" do
        page("index.erb").process!
        assert_equal File.read(output_dir("index.html")), page.render
      end
    
      should "write the filtered body to a new file using the extension in the meta_data" do
        page("feed.haml").process!
        assert_equal File.read(output_dir("feed.rss")), page.render(false)
      end
    
      should "write the filtered body to a new file with a pretty URL scheme in the output dir" do
        page("about_us.erb").process!
        assert_equal File.read(output_dir("about-us", "index.html")), page.render(false)
      end
    
      teardown { clear_output }
    
    end
  end
end
