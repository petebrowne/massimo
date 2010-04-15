require File.expand_path('../spec_helper', __FILE__)

describe Massimo do
  describe '.site' do
    it 'should return a Site' do
      Massimo.site.should be_an_instance_of(Massimo::Site)
    end
    
    context 'when a Site has been created' do
      it 'should return that site' do
        site = Massimo::Site.new
        Massimo.site.should === site
      end
    end
  end
  
  describe '.config' do
    it 'should return the configuration to the current Site' do
      Massimo::Site.new :source_path => 'source/dir'
      Massimo.config.source_path.should == File.expand_path('source/dir')
    end
  end
end
