require "helper"

class TestStylesheet < Test::Unit::TestCase
  should "render CSS stylesheets" do
    stylesheet = Massimo::Stylesheet.new(site, source_dir("stylesheets", "basic.css"))
    assert_equal stylesheet.render, "body {\n  font-size: 12px;\n}"
  end
  
  should "render Sass stylesheets" do
    stylesheet = Massimo::Stylesheet.new(site, source_dir("stylesheets", "application.sass"))
    assert_equal stylesheet.render, "body {\n  font-size: 12px; }\n\n#header {\n  font-size: 36px; }\n"
  end
  
  should "render Less stylesheets" do
    stylesheet = Massimo::Stylesheet.new(site, source_dir("stylesheets", "less_file.less"))
    assert_equal stylesheet.render, "#header { color: #4d926f; }\n"
  end
  
  context "processing Stylesheets" do
    should "output the css file to the stylesheets dir" do
      Massimo::Stylesheet.new(site, source_dir("stylesheets", "application.sass")).process!
      assert_equal File.read(output_dir("stylesheets", "application.css")), "body {\n  font-size: 12px; }\n\n#header {\n  font-size: 36px; }\n"
    end
    
    teardown { clear_output }
  end
  
end
