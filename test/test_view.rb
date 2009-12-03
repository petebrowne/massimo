require File.join(File.dirname(__FILE__), "helper")

class TestView < Test::Unit::TestCase
  context "View without locals" do
    setup { view("without_locals.haml") }
    
    should "fetch the body from the view file" do
      assert_equal "%h1 A Partial", @view.body
    end
    
    should "render the content from the view file correctly" do
      assert_equal "<h1>A Partial</h1>\n", @view.render
    end
  end
  
  context "View with locals" do
    setup { view("with_locals.haml", :title => "A Partial") }
    
    should "render the content from the page file correctly" do
      assert_equal "<h1>A Partial</h1>\n", @view.render
    end
    
    should "be able to access meta_data directly" do
      assert_equal "A Partial", @view.title
    end
    
    should "be able to write new meta_data dynamically" do
      @view.new_data = "test"
      assert_equal "test", @view.new_data
    end
  end
end
