require File.expand_path('../spec_helper', __FILE__)

describe Massimo::View do
  describe '#render' do
    it 'should use Tilt to render the templates' do
      within_construct do |c|
        c.file 'index.erb'
        stub(template = Object.new).render
        mock(Tilt).new('index.erb') { template }
        Massimo::View.new('index.erb').render
      end
    end
    
    context 'with a locals hash' do
      it 'should use the locals when rendering' do
        within_construct do |c|
          c.file 'index.haml', '%h1= local'
          view = Massimo::View.new 'index.haml'
          view.render(:local => 'Local').should == "<h1>Local</h1>\n"
        end
      end
    end
    
    context 'with a content block' do
      it 'should yield the content' do
        within_construct do |c|
          c.file 'index.erb', '<%= yield %>'
          view = Massimo::View.new 'index.erb'
          view.render { 'Content' }.should == 'Content'
        end
      end
    end
  end
end
