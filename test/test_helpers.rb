require File.expand_path("../helper", __FILE__)

class TestHelpers < Test::Unit::TestCase
  context "A Site's Helpers" do
    setup do
      @helpers = site().helpers
    end
    
    should "include sinatra_more's helper methods" do
      assert @helpers.class.include?(SinatraMore::OutputHelpers)
      assert @helpers.class.include?(SinatraMore::TagHelpers)
      assert @helpers.class.include?(SinatraMore::AssetTagHelpers)
      assert @helpers.class.include?(SinatraMore::FormHelpers)
      assert @helpers.class.include?(SinatraMore::FormatHelpers)
    end
    
    should "have a method for accessing the Site" do
      assert_equal @site, @helpers.site
    end
    
    should "have a method for rendering views like partials" do
      assert_equal "<h1>Testing</h1>\n", @helpers.render("with_locals", :title => "Testing")
    end
  end
end
