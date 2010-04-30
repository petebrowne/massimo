require File.expand_path('../spec_helper', __FILE__)

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
      within_construct do |c|
        c.file 'page.erb', page_content
        page.title.should == 'A Page'
      end
    end
    
    it 'should create attributes for each key in the #meta_data' do
      within_construct do |c|
        c.file 'page.erb', page_content
        page.created_at.should_not be_nil
      end
    end
    
    it 'should report the #created_at attribute has been set' do
      within_construct do |c|
        c.file 'page.erb', page_content
        page.created_at?.should === true
      end
    end
    
    it 'should report the correct line number to Tilt' do
      within_construct do |c|
        c.file 'page.erb', <<-CONTENT.unindent
          ---
          title: A Page
          ---
          <%= raise 'Error' %>
        CONTENT
        begin
          page.render
        rescue Exception => error
          error.backtrace.first.should =~ /:4:/
        end
      end
    end
    
    it 'should include the meta_data as locals when rendering' do
      within_construct do |c|
        c.file 'page.erb', page_content
        page.render.should include('A Page')
      end
    end
  end
  
  context 'without meta data' do
    let(:page) { Massimo::Page.new 'without_meta_data.erb' }
    
    it 'should create the #title from the filename' do
      within_construct do |c|
        c.file 'without_meta_data.erb'
        page.title.should == 'Without Meta Data'
      end
    end
    
    it "should default the #extension to '.html'" do
      within_construct do |c|
        c.file 'without_meta_data.erb'
        page.extension.should == '.html'
      end
    end
    
    it "should default the #layout to 'application'" do
      within_construct do |c|
        c.file 'without_meta_data.erb'
        page.layout.should == 'main'
      end
    end
    
    it 'should report the #created_at attribute has not been set' do
      within_construct do |c|
        c.file 'without_meta_data.erb'
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
      within_construct do |c|
        c.file 'new_page.erb', '<%= new_page.title %>'
        NewPage.new('new_page.erb').render.should == 'New Page'
      end
    end
    
    it 'should pass config options for the template' do
      Massimo.config.haml = { :attr_wrapper => %(") }
      within_construct do |c|
        c.file 'new_page.haml', '#header Title'
        Massimo::Page.new('new_page.haml').render.should == %(<div id="header">Title</div>\n)
      end
    end
  end
  
  describe '#url' do
    it 'should be a pretty url based on the filename' do
      within_construct do |c|
        c.file 'pages/about-us.erb'
        Massimo::Page.new('pages/about-us.erb').url.should == '/about-us/'
      end
    end
    
    context 'with a root directory index' do
      it "should be '/'" do
        within_construct do |c|
          c.file 'pages/index.erb'
          Massimo::Page.new('pages/index.erb').url.should == '/'
        end
      end
    end
    
    context 'with a nested directory index' do
      it 'should drop the filename' do
        within_construct do |c|
          c.file 'pages/some/url/index.haml'
          Massimo::Page.new('pages/some/url/index.haml').url.should == '/some/url/'
        end
      end
    end
    
    context "when the extension is not '.html'" do
      it 'should not create a pretty url' do
        within_construct do |c|
          c.file 'pages/about-us.rss', "---\nextension: .rss\n---"
          Massimo::Page.new('pages/about-us.rss').url.should == '/about-us.rss'
        end
      end
    end
  end
  
  describe '#output_path' do
    it 'should re-add directory index file names' do
      within_construct do |c|
        c.file 'pages/some/url/index.html'
        resource = Massimo::Page.new('pages/some/url/index.html')
        resource.output_path.to_s.should == File.expand_path('public/some/url/index.html')
      end
    end
    
    context 'with a root url' do
      it 'should add the directory index' do
        within_construct do |c|
          c.file 'pages/index.erb'
          Massimo::Page.new('pages/index.erb').output_path.to_s.should == File.expand_path('public/index.html')
        end
      end
    end
    
    context 'with a pretty url' do
      it 'should create a directory index file' do
        within_construct do |c|
          c.file 'pages/about-us.erb'
          Massimo::Page.new('pages/about-us.erb').output_path.to_s.should == File.expand_path('public/about-us/index.html')
        end
      end
    end
  end
end
