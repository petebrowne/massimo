require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Resource do
  let(:resource) { Massimo::Resource.new './file.txt' }
  
  describe '#initialize' do
    it 'should require the #source_path to the file' do
      expect { Massimo::Resource.new }.to raise_error
    end
  end
  
  describe '#source_path' do
    context 'when set with a string' do
      it 'should be a Pathname object' do
        resource.source_path.should be_an_instance_of(Pathname)
      end
    end
  end
  
  describe '#output_path' do
    it 'should be a Pathname object' do
      resource.output_path.should be_an_instance_of(Pathname)
    end
    
    it 'should move the #source_path to the sites output dir' do
      resource.output_path.to_s.should == './public/file.txt'
    end
  end
  
  describe '#content' do
    it "should read the associated file's content" do
      within_construct do |c|
        c.file('file.txt', 'content')
        resource.content.should == 'content'
      end
    end
  end
  
  describe '#render' do
    it "should return the file's content" do
      within_construct do |c|
        c.file('file.txt', 'content')
        resource.render.should == 'content'
      end
    end
  end
  
  describe '#process' do
    it 'should create a file with the rendered content' do
      within_construct do |c|
        c.file('file.txt', 'content')
        resource.process
        File.read('./public/file.txt').should == 'content'
      end
    end
  end
end
