require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Config do
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
      config.url_for(:pages).should == '/pages'
    end
    
    it "should default to '/'" do
      Massimo::Config.new.url_for(:users).should == '/'
    end
    
    context 'with a custom #base_url' do
      it 'should prepend the #base_url' do
        config = Massimo::Config.new :base_url => '/blog'
        config.url_for(:stylesheets).should == '/blog/stylesheets'
      end
    end
  end
  
  describe '#files_in' do
    it 'should find each file in the given resource dir' do
      within_construct do |c|
        c.file 'lib/some_file.rb'
        c.file 'lib/another_file.txt'
        files = Massimo::Config.new.files_in(:lib).map { |file| File.basename(file) }
        files.should =~ %w( some_file.rb another_file.txt )
      end
    end
    
    it 'should not find directories' do
      within_construct do |c|
        c.directory 'pages/some_dir'
        files = Massimo::Config.new.files_in(:pages)
        files.should_not include(File.expand_path('pages/some_dir'))
      end
    end
    
    it 'should find files with the given extension' do
      within_construct do |c|
        c.file 'lib/some_file.rb'
        c.file 'lib/another_file.txt'
        files = Massimo::Config.new.files_in(:lib, 'rb')
        files.should_not include(File.expand_path('lib/another_file.txt'))
      end
    end
  end
  
  describe '#options_for' do
    it 'should return the options set for the given name' do
      config = Massimo::Config.new(:sass => { :style => :compressed })
      config.options_for(:sass).should == { :style => :compressed }
    end
    
    it 'should return an empty hash if the options have not been set' do
      Massimo::Config.new.options_for(:sass).should == {}
    end
  end
  
  describe '#environment' do
    it 'should be a StringInquirer' do
      config = Massimo::Config.new :environment => 'production'
      config.environment.should be_an_instance_of(ActiveSupport::StringInquirer)
    end
  end
end
