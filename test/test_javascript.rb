require File.expand_path("../helper", __FILE__)

class TestJavascript < Test::Unit::TestCase
  context "A Site" do
    setup { site() }
    
    should "concat js using Sprockets" do
      javascript = Massimo::Javascript.new(source_dir("javascripts", "application.js"))
      assert_equal %{var plugin = "plugin";\n\nvar application = "application";\n}, javascript.render
    end
  
    context "processing Javascripts" do
      should "output the js file to the javascripts dir" do
        Massimo::Javascript.new(source_dir("javascripts", "application.js")).process!
        assert_equal %{var plugin = "plugin";\n\nvar application = "application";\n}, File.read(output_dir("javascripts", "application.js"))
      end
    
      teardown { clear_output }
    end
  end
  
  context "A Production Site" do
    setup { site(:production => true) }
    
    should "minify js" do
      javascript = Massimo::Javascript.new(source_dir("javascripts", "application.js"))
      assert_equal %{\nvar plugin="plugin";var application="application";}, javascript.render
    end
  end
end
