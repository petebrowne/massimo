require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Page do
  context 'with meta data' do
    let(:page) { Massimo::Page.new 'page.erb' }
    let(:page_content) do
      <<-STR.unindent
        ---
        title: A Page
        created_at: 2010-04-01
        url: a/messy/url
        ---
        <%= title %>
        <%= created_at.strftime('%m-%Y') %>
      STR
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
    
    it 'should report the correct line number to Tilt' do
      within_construct do |c|
        c.file 'page.erb', page_content
        stub(template = Object.new).render
        mock(Tilt).new('page.erb', 6) { template }
        page.render
      end
    end
    
    it "should ensure urls start with a '/'" do
      within_construct do |c|
        c.file 'page.erb', page_content
        page.url.should =~ /^\//
      end
    end
  end
  
  context 'without meta data' do
    let(:page) { Massimo::Page.new 'without_meta_data.erb' }
    
    it 'should create the title from the filename' do
      within_construct do |c|
        c.file 'without_meta_data.erb'
        page.title.should == 'Without Meta Data'
      end
    end
    
    it 'should default the extension to .html' do
      within_construct do |c|
        c.file 'without_meta_data.erb'
        page.extension.should == '.html'
      end
      
    end
    it 'should create the url from the filename' do
      within_construct do |c|
        c.file 'without_meta_data.erb'
        page.url.should == '/without-meta-data'
      end
    end
    
    it "should prepend the Resource's url to the url" do
      Massimo.config.pages_url = '/pages'
      within_construct do |c|
        c.file 'without_meta_data.erb'
        page.url.should == '/pages/without-meta-data'
      end
    end
  end
end
