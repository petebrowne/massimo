require File.join(File.dirname(__FILE__), "helper")

class TestResource < Test::Unit::TestCase
  context "A site" do
    setup { site() }
    
    should "raise an error when reading a non-existent resource" do
      assert_raise Massimo::MissingResource do
        Massimo::Resource.new("some/non-existent/file")
      end
    end
  
    should "raise an error when reading an invalid resource" do
      assert_raise Massimo::InvalidResource do
        Massimo::Resource.new(source_dir("views", "layouts"))
      end
    end
  
    should "have a method to get the resource's type (extension)" do
      assert_equal Massimo::Resource.new(source_dir("pages", "about_us.erb")).resource_type, "erb"
    end
  
    should "render the resource files data" do
      assert_equal Massimo::Resource.new(source_dir("pages", "without_meta_data.haml")).render, "%h1 A Page without meta_data"
    end
  end
end
