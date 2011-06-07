require 'spec_helper'

describe Massimo::Config do
  its(:config_path)     { should == File.expand_path('config.rb') }
  its(:source_path)     { should == File.expand_path('.') }
  its(:output_path)     { should == File.expand_path('public') }
  its(:environment)     { should == 'development' }
  its(:resources_path)  { should == '.' }
  its(:base_url)        { should == '/' }
  its(:resources_url)   { should == '/' }
  its(:javascripts_url) { should == '/javascripts' }
  its(:stylesheets_url) { should == '/stylesheets' }
  
  describe '#initialize' do
    context 'with an options hash' do
      it 'sets the given attributes' do
        config = Massimo::Config.new :source_path => 'source/path'
        config.source_path.should == File.expand_path('source/path')
      end
    end
  end
  
  describe '#path_for' do
    it 'reads the configured option' do
      config = Massimo::Config.new :pages_path => 'pages/path'
      config.path_for(:pages).should == File.expand_path('pages/path')
    end
    
    it 'defaults to a path in the #source_path' do
      Massimo::Config.new.path_for(:pages).should == File.expand_path('pages')
    end
  end
  
  describe '#url_for' do
    it 'reads the configured option' do
      config = Massimo::Config.new :pages_url => '/pages'
      config.url_for(:pages).should == '/pages'
    end
    
    it "defaults to '/'" do
      Massimo::Config.new.url_for(:users).should == '/'
    end
    
    context 'with a custom #base_url' do
      it 'prepends the #base_url' do
        config = Massimo::Config.new :base_url => '/blog'
        config.url_for(:stylesheets).should == '/blog/stylesheets'
      end
    end
  end
  
  describe '#files_in' do
    it 'finds each file in the given resource dir' do
      within_construct do |c|
        c.file 'lib/some_file.rb'
        c.file 'lib/another_file.txt'
        files = Massimo::Config.new.files_in(:lib).map { |file| File.basename(file) }
        files.should =~ %w( some_file.rb another_file.txt )
      end
    end
    
    it 'does not find directories' do
      within_construct do |c|
        c.directory 'pages/some_dir'
        files = Massimo::Config.new.files_in(:pages)
        files.should_not include(File.expand_path('pages/some_dir'))
      end
    end
    
    it 'finds files with the given extension' do
      within_construct do |c|
        c.file 'lib/some_file.rb'
        c.file 'lib/another_file.txt'
        files = Massimo::Config.new.files_in(:lib, 'rb')
        files.should_not include(File.expand_path('lib/another_file.txt'))
      end
    end
  end
  
  describe '#options_for' do
    it 'returns the options set for the given name' do
      config = Massimo::Config.new(:sass => { :style => :compressed })
      config.options_for(:sass).should == { :style => :compressed }
    end
    
    it 'returns an empty hash if the options have not been set' do
      Massimo::Config.new.options_for(:sass).should == {}
    end
  end
  
  describe '#environment' do
    it 'is a StringInquirer' do
      config = Massimo::Config.new :environment => 'production'
      config.environment.should be_an_instance_of(ActiveSupport::StringInquirer)
    end
  end
  
  describe '#compress_js?' do
    it 'defaults to false' do
      Massimo::Config.new.compress_js?.should be_false
    end
    
    it 'reads the configured options' do
      config = Massimo::Config.new :compress_js => true
      config.compress_js?.should be_true
    end
    
    it 'returns true in a production environment' do
      config = Massimo::Config.new :environment => 'production'
      config.compress_js?.should be_true
    end
  end
  
  describe '#js_compressor=' do
    it 'prefers the given compressor using Crush' do
      mock(Crush).prefer(:uglifier, "js")
      config = Massimo::Config.new
      config.js_compressor = :uglifier
    end
    
    it 'sets compress_js to true' do
      config = Massimo::Config.new
      config.js_compressor = :uglifier
      config.compress_js?.should be_true
    end
  end
  
  describe '#compress_css?' do
    it 'defaults to false' do
      Massimo::Config.new.compress_css?.should be_false
    end
    
    it 'reads the configured options' do
      config = Massimo::Config.new :compress_css => true
      config.compress_css?.should be_true
    end
    
    it 'returns true in a production environment' do
      config = Massimo::Config.new :environment => 'production'
      config.compress_css?.should be_true
    end
  end
  
  describe '#css_compressor=' do
    it 'prefers the given compressor using Crush' do
      mock(Crush).prefer(:cssmin, "css")
      config = Massimo::Config.new
      config.css_compressor = :cssmin
    end
    
    it 'sets compress_js to true' do
      config = Massimo::Config.new
      config.css_compressor = :cssmin
      config.compress_css?.should be_true
    end
  end
end