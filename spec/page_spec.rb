require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Page do
  context 'with meta data' do
    let(:page) { Massimo::Page.new 'page.erb' }
    let(:page_content) do
      <<-STR.unindent
        ---
        title: A Page
        created_at: 2010-04-01
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
    
    it 'should report the #created_at attribute has been set' do
      within_construct do |c|
        c.file 'page.erb', page_content
        page.created_at?.should === true
      end
    end
    
    it 'should report the correct line number to Tilt' do
      within_construct do |c|
        c.file 'page.erb', page_content
        stub(template = Object.new).render
        mock(Tilt).new('page.erb', 5) { template }
        page.render
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
        page.layout.should == 'application'
      end
    end
    
    it 'should report the #created_at attribute has not been set' do
      within_construct do |c|
        c.file 'without_meta_data.erb'
        page.created_at?.should === false
      end
    end
  end
end
