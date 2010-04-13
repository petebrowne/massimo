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
        page.meta_data['title'].should == 'A Page'
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
end
