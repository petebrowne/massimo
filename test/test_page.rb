require "helper"

class TestPage < Test::Unit::TestCase
  
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
      assert_equal @page.new_tag, "test"
    end
  end
  
  context "Page with title" do
    setup { page("with_title.haml") }
    
    should "fetch the title from the meta_data" do
      assert_equal @page.title, "A Title"
    end
  end
  
  context "Page without title" do
    setup { page("without_title.haml") }
    
    should "create the title from the file name" do
      assert_equal @page.title, "Without Title"
    end
  end
  
  context "Page with extension" do
    setup { page("with_extension.haml") }
    
    should "fetch the extension from the meta_data" do
      assert_equal @page.extension, ".rss"
    end
  end
  
  context "Page without extension" do
    setup { page("without_extension.haml") }
    
    should "default to .html" do
      assert_equal @page.extension, ".html"
    end
  end
  
  context "Page with URL" do
    setup { page("with_url.haml") }
    
    should "fetch the extension from the meta_data" do
      assert_equal @page.url, "/page-with-url"
    end
  end
  
  context "Page without URL" do
    setup { page("without_url.haml") }
    
    should "default to .html" do
      assert_equal @page.url, "/without-url"
    end
  end
    
  should "fetch the body from the page file" do
    assert_equal page("about_us.erb").body, %{<h1>An <%= "HTML" %> Page</h1>}
  end
  
  context "rendering Pages" do
    context "without layouts" do
      
      should "filter the content from the page file correctly" do
        assert_equal page("about_us.erb").render(false), "<h1>An HTML Page</h1>"
      end
      
    end
    context "with layouts" do
      
      should "filter the content from the page file correctly" do
        assert_equal page("index.erb").render, "<div><h1>Home</h1></div>\n"
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
