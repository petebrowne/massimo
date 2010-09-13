require 'spec_helper'

describe Massimo::View do
  describe '#render' do
    it 'should use Tilt to render the templates' do
      with_file 'index.erb' do
        stub(template = Object.new).render
        mock(Tilt).new(anything, anything, anything) { template }
        Massimo::View.new('index.erb').render
      end
    end
    
    context 'with a locals hash' do
      it 'should use the locals when rendering' do
        with_file 'index.haml', '%h1= local' do
          view = Massimo::View.new 'index.haml'
          view.render(:local => 'Local').should == "<h1>Local</h1>\n"
        end
      end
    end
    
    context 'with a content block' do
      it 'should yield the content' do
        with_file 'index.erb', '<%= yield %>' do
          view = Massimo::View.new 'index.erb'
          view.render { 'Content' }.should == 'Content'
        end
      end
    end
    
    it 'should use Site#template_scope as the scope' do
      within_construct do |c|
        c.file 'index.erb', "<%= render 'partial' %>"
        c.file 'views/partial.erb', 'Partial'
        Massimo::View.new('index.erb').render.should == 'Partial'
      end
    end
    
    it 'should pass config options for the template' do
      Massimo.config.haml = { :attr_wrapper => %(") }
      with_file 'view.haml', '#header Title' do
        Massimo::View.new('view.haml').render.should == %(<div id="header">Title</div>\n)
      end
    end
  end
end
