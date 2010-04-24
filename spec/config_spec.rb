require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Config do
  its(:source_path)     { should == File.expand_path('.') }
  its(:output_path)     { should == File.expand_path('public') }
  its(:resources_path)  { should == '.' }
  its(:resources_url)   { should == '/' }
  its(:javascripts_url) { should == '/javascripts' }
  its(:stylesheets_url) { should == '/stylesheets' }
  
  describe '#initialize' do
    context 'with an options hash' do
      it 'should set the given attributes' do
        config = Massimo::Config.new :source_path => 'source/path'
        config.source_path.should == File.expand_path('source/path')
      end
    end
    
    context 'with a string' do
      it 'should read a YAML file for configuration' do
        within_construct do |c|
          c.file 'config.yml', "source_path: source/path\n"
          config = Massimo::Config.new 'config.yml'
          config.source_path.should == File.expand_path('source/path')
        end
      end
    end
  end
  
  describe '#path_for' do
    it 'should read the configured option' do
      config = Massimo::Config.new :pages_path => 'pages/path'
      config.path_for(:pages).should == File.expand_path('pages/path')
    end
    
    it 'should default to a path in the #source_path' do
      Massimo::Config.new.path_for(:pages).should == File.expand_path('pages')
    end
  end
  
  describe '#url_for' do
    it 'should read the configured option' do
      config = Massimo::Config.new :pages_url => '/pages'
      config.url_for('pages').should == '/pages'
    end
    
    it "should default to '/'" do
      Massimo::Config.new.url_for('users').should == '/'
    end
  end
end
