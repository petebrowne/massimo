require File.join(File.dirname(__FILE__), "helper")

class TestJavascript < Test::Unit::TestCase
  context "A site" do
    setup { site() }
    
    should "concat js using Sprockets" do
      javascript = Massimo::Javascript.new(source_dir("javascripts", "application.js"))
      assert_equal javascript.render, %{\nvar plugin="plugin";var application="application";}
    end
  
    context "processing Javascripts" do
      should "output the js file to the javascripts dir" do
        Massimo::Javascript.new(source_dir("javascripts", "application.js")).process!
        assert_equal File.read(output_dir("javascripts", "application.js")), %{\nvar plugin="plugin";var application="application";}
      end
    
      teardown { clear_output }
    end
  end
end
