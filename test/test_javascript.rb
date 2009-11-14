require "helper"

class TestJavascript < Test::Unit::TestCase
  should "concat js using Sprockets" do
    javascript = Massimo::Javascript.new(site, source_dir("javascripts", "application.js"))
    assert_equal javascript.render, %{\nvar plugin="plugin";var application="application";}
  end
  
  context "processing Javascripts" do
    should "output the js file to the javascripts dir" do
      Massimo::Javascript.new(site, source_dir("javascripts", "application.js")).process!
      assert_equal File.read(output_dir("javascripts", "application.js")), %{\nvar plugin="plugin";var application="application";}
    end
    
    teardown { clear_output }
  end
  
end
