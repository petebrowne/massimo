require 'spec_helper'

describe Massimo::Page do
  context 'with meta data' do
    let(:page) { Massimo::Page.new 'page.erb' }
    
    let(:page_content) do
      <<-CONTENT.unindent
        ---
        title: A Page
        created_at: 2010-04-01
        ---
        <%= title %>
        <%= created_at.strftime('%m-%Y') %>
      CONTENT
    end
    
    it 'should read the meta data into a #meta_data hash' do
      with_file 'page.erb', page_content do
        page.title.should == 'A Page'
      end
    end
    
    it 'should create attributes for each key in the #meta_data' do
      with_file 'page.erb', page_content do
        page.created_at.should_not be_nil
      end
    end
    
    it 'should report the #created_at attribute has been set' do
      with_file 'page.erb', page_content do
        page.created_at?.should === true
      end
    end
    
    it 'should report the correct line number to Tilt' do
      content = <<-CONTENT.unindent
        ---
        title: A Page
        ---
        <%= raise 'Error' %>
      CONTENT
      with_file 'page.erb', content do
        begin
          page.render
        rescue Exception => error
          error.backtrace.first.should =~ /:4:/
        end
      end
    end
    
    it 'should include the meta_data as locals when rendering' do
      with_file 'page.erb', page_content do
        page.render.should include('A Page')
      end
    end
  end
  
  context 'without meta data' do
    let(:page) { Massimo::Page.new 'without_meta_data.erb' }
    
    it 'should create the #title from the filename' do
      with_file 'without_meta_data.erb' do
        page.title.should == 'Without Meta Data'
      end
    end
    
    it "should default the #extension to '.html'" do
      with_file 'without_meta_data.erb' do
        page.extension.should == '.html'
      end
    end
    
    it "should default the #layout to 'application'" do
      with_file 'without_meta_data.erb' do
        page.layout.should == 'main'
      end
    end
    
    it 'should report the #created_at attribute has not been set' do
      with_file 'without_meta_data.erb' do
        page.created_at?.should === false
      end
    end
  end
  
  describe '#render' do
    let(:page) { Massimo::Page.new 'page.erb' }
    
    context 'with layouts' do
      it 'should wrap the content in a layout' do
        within_construct do |c|
          c.file 'page.erb'
          c.file 'views/layouts/main.erb', 'Layout'
          page.render.should == 'Layout'
        end
      end
      
      it 'should include the content with #yield' do
        within_construct do |c|
          c.file 'page.erb', 'Content'
          c.file 'views/layouts/main.erb', '<%= yield %>'
          page.render.should == 'Content'
        end
      end
      
      it 'should include the page as a local' do
        within_construct do |c|
          c.file 'page.erb', "---\ntitle: A Page\n---"
          c.file 'views/layouts/main.erb', "<%= page.title %>"
          page.render.should == 'A Page'
        end
      end
      
      it 'should not render the layout if #layout is false' do
        within_construct do |c|
          c.file 'page.erb', "---\nlayout: false\n---\nContent"
          c.file 'views/layouts/main.erb', 'Layout'
          puts page.layout
          page.render.should_not include('Layout')
        end
      end
    end
    
    it 'should use Site#template_scope as the scope' do
      within_construct do |c|
        c.file 'index.erb', "<%= render 'partial' %>"
        c.file 'views/partial.erb', 'Partial'
        Massimo::Page.new('index.erb').render.should == 'Partial'
      end
    end
    
    it 'should include a local that references itself' do
      NewPage = Class.new(Massimo::Page)
      with_file 'new_page.erb', '<%= new_page.title %>' do
        NewPage.new('new_page.erb').render.should == 'New Page'
      end
    end
    
    it 'should pass config options for the template' do
      Massimo.config.haml = { :attr_wrapper => %(") }
      with_file 'new_page.haml', '#header Title' do
        Massimo::Page.new('new_page.haml').render.should == %(<div id="header">Title</div>\n)
      end
    end
  end
  
  describe '#url' do
    it 'should be a pretty url based on the filename' do
      with_file 'pages/about-us.erb' do
        Massimo::Page.new('pages/about-us.erb').url.should == '/about-us/'
      end
    end
    
    context 'with a root directory index' do
      it "should be '/'" do
        with_file 'pages/index.erb' do
          Massimo::Page.new('pages/index.erb').url.should == '/'
        end
      end
    end
    
    context 'with a nested directory index' do
      it 'should drop the filename' do
        with_file 'pages/some/url/index.haml' do
          Massimo::Page.new('pages/some/url/index.haml').url.should == '/some/url/'
        end
      end
    end
    
    context "when the extension is not '.html'" do
      it 'should not create a pretty url' do
        with_file 'pages/about-us.rss', "---\nextension: .rss\n---" do
          Massimo::Page.new('pages/about-us.rss').url.should == '/about-us.rss'
        end
      end
    end
  end
  
  describe '#output_path' do
    it 'should re-add directory index file names' do
      with_file 'pages/some/url/index.html' do
        resource = Massimo::Page.new('pages/some/url/index.html')
        resource.output_path.to_s.should == File.expand_path('public/some/url/index.html')
      end
    end
    
    context 'with a root url' do
      it 'should add the directory index' do
        with_file 'pages/index.erb' do
          Massimo::Page.new('pages/index.erb').output_path.to_s.should == File.expand_path('public/index.html')
        end
      end
    end
    
    context 'with a pretty url' do
      it 'should create a directory index file' do
        with_file 'pages/about-us.erb' do
          Massimo::Page.new('pages/about-us.erb').output_path.to_s.should == File.expand_path('public/about-us/index.html')
        end
      end
    end
  end
  
  context 'as a .yml file' do
    it 'should treat the whole file as front matter' do
      with_file 'pages/data.yml', 'name: Joe' do
        Massimo::Page.new('pages/data.yml').name.should == 'Joe'
      end
    end
    
    it 'should default content to an empty string' do
      with_file 'pages/data.yml', 'name: Joe' do
        Massimo::Page.new('pages/data.yml').content.should == ''
      end
    end
    
    it 'should set the content with a content attribute' do
      with_file 'pages/data.yml', 'content: Some Content' do
        Massimo::Page.new('pages/data.yml').content.should == 'Some Content'
      end
    end
  end
end
