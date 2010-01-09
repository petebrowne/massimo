require File.join(File.dirname(__FILE__), "helper")

class TestResource < Test::Unit::TestCase
  context "A site" do
    setup { site() }
    
    should "raise an error when reading a non-existent resource" do
      assert_raise Massimo::MissingResource do
        Massimo::Resource::Base.new("some/non-existent/file")
      end
    end
  
    should "raise an error when reading an invalid resource" do
      assert_raise Massimo::InvalidResource do
        Massimo::Resource::Base.new(source_dir("views", "layouts"))
      end
    end
  
    should "have a method to get the resource's type (extension)" do
      assert_equal Massimo::Resource::Base.new(source_dir("pages", "about_us.erb")).resource_type, "erb"
    end
  
    should "render the resource files data" do
      assert_equal Massimo::Resource::Base.new(source_dir("pages", "without_meta_data.haml")).render, "%h1 A Page without meta_data"
    end
    
    context "with unprocessable Resources" do
      should "not process resources when process! is called" do
        assert Massimo::View.processable? == false
        assert view("with_locals.haml").process! == false
      end
    end
    
    context "with Resource collections" do
      should "find only the pages set in the :pages option" do
        only_pages = %w{about_us.erb feed.haml index.erb}
        site(:pages => only_pages)
        page_paths = Massimo::Page.all(true).collect { |page| page.source_path.basename }
        assert_equal_arrays only_pages, page_paths
      end
  
      should "skip pages set in the :skip_pages option (as an Array)" do
        site(:skip_pages => %w{about_us.erb erb.erb erb_with_layout.erb feed.haml posts/first-post.haml haml.haml html.html index.erb markdown.markdown})
        page_paths = Massimo::Page.all(true).collect { |page| page.source_path.basename }
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
        site(:skip_pages => lambda { |file| file.include?("with") })
        page_paths = Massimo::Page.all(true).collect { |page| page.source_path.basename }
        assert_equal_arrays %w{about_us.erb erb.erb feed.haml first-post.haml haml.haml html.html index.erb markdown.markdown}, page_paths
      end
      
      should "not skip any pages when :skip_pages is set incorrectly" do
        site(:skip_pages => 15)
        page_paths = Massimo::Page.all(true).collect { |page| page.source_path.basename }
        assert_equal_arrays source_page_paths, page_paths
      end
    end
  end
end
