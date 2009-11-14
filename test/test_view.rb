require "helper"

class TestView < Test::Unit::TestCase
  context "View without locals" do
    setup { view("without_locals.haml") }
    
    should "fetch the body from the view file" do
      assert_equal @view.body, "%h1 A Partial"
    end
    
    should "render the content from the view file correctly" do
      assert_equal @view.render, "<h1>A Partial</h1>\n"
    end
  end
  
  context "View with locals" do
    setup { view("with_locals.haml", :title => "A Partial") }
    
    should "render the content from the page file correctly" do
      assert_equal @view.render, "<h1>A Partial</h1>\n"
    end
    
    should "be able to access meta_data directly" do
      assert_equal @view.title, "A Partial"
    end
    
    should "be able to write new meta_data dynamically" do
      @view.new_data = "test"
      assert_equal @view.new_data, "test"
    end
  end
end
