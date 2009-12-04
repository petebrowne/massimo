require File.join(File.dirname(__FILE__), "helper")

class TestFilters < Test::Unit::TestCase
  
  context "adding filters" do
    should "be able to manipulate data through a filter" do
      Massimo::Filters.register(:upcase) do |data, template, locals|
        data.to_s.upcase
      end
      assert_equal Massimo.filter("case", :upcase), "CASE"
    end
  
    should "be able to find a filter with multiple extensions" do
      extensions = %w{ext_a ext_b ext_c}
      Massimo::Filters.register(extensions) do |data, template, locals|
        data.to_s.downcase
      end
      extensions.each do |ext|
        assert_equal Massimo.filter("CASE", ext),  "case"
      end
    end
  end
  
  should "get filter extensions" do
    assert_equal Massimo::Filters.extensions.map(&:to_s).sort, %w{erb haml html markdown md php rb ruby textile}
  end
  
  context "filter support" do
    should "return the given data when no filter is found" do
      data = "Some Data"
      assert_equal Massimo.filter(data, :missing_filter), data
    end
    
    should "have support for filtering html and php" do
      [ :html, :php ].each do |ext|
        assert_equal Massimo.filter("<h1>Header</h1>", ext), "<h1>Header</h1>"
      end
    end
  
    should "have support for filtering rb (ruby)" do
      ruby_code = <<-END
        test  = "Ruby"
        test << " "
        test << "Code"
        test
      END
      assert_equal Massimo.filter(ruby_code, :rb), "Ruby Code"
    end
  
    should "have support for filtering haml" do
      assert_equal Massimo.filter("%h1= title", :haml, nil, :title => "Header"), "<h1>Header</h1>\n"
    end
  
    should "have support for using helpers in haml" do
      assert_nothing_raised do
        Massimo.filter(%{= stylesheet_link_tag "main"}, :haml, site.template)
      end
    end
  
    should "have support for filtering erb" do
      assert_equal Massimo.filter("<h1><%= title %></h1>", :erb, nil, :title => "Header"), "<h1>Header</h1>"
    end
  
    should "have support for filtering textile" do
      assert_equal Massimo.filter("h1. <%= title %>", :textile, nil, :title => "Header"), "<h1>Header</h1>"
    end
  
    should "have support for filtering markdown" do
      assert_equal Massimo.filter("# <%= title %>", :markdown, nil, :title => "Header"), "<h1>Header</h1>\n"
    end
  end
  
end
