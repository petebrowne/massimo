require File.join(File.dirname(__FILE__), "helper")

class TestStylesheet < Test::Unit::TestCase
  context "A Site" do
    setup { site() }
  
    should "render CSS stylesheets" do
      stylesheet = Massimo::Stylesheet.new(source_dir("stylesheets", "basic.css"))
      assert_equal "body {\n  font-size: 12px;\n}", stylesheet.render
    end
  
    should "render Sass stylesheets" do
      stylesheet = Massimo::Stylesheet.new(source_dir("stylesheets", "application.sass"))
      assert_equal "body {\n  font-size: 12px; }\n\n#header {\n  font-size: 36px; }\n", stylesheet.render
    end
  
    should "render Less stylesheets" do
      stylesheet = Massimo::Stylesheet.new(source_dir("stylesheets", "less_file.less"))
      assert_equal "#header { color: #4d926f; }\n", stylesheet.render
    end
  
    context "processing Stylesheets" do
      should "output the css file to the stylesheets dir" do
        Massimo::Stylesheet.new(source_dir("stylesheets", "application.sass")).process!
        assert_equal "body {\n  font-size: 12px; }\n\n#header {\n  font-size: 36px; }\n", File.read(output_dir("stylesheets", "application.css"))
      end
    
      teardown { clear_output }
    end
  end
  
  context "A Production Site" do
    setup { site(:production => true)}
    
    should "should compress Sass stylesheets" do
      stylesheet = Massimo::Stylesheet.new(source_dir("stylesheets", "application.sass"))
      assert_equal "body{font-size:12px}#header{font-size:36px}\n", stylesheet.render
    end
  end
end
