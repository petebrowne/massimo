require 'spec_helper'

describe Massimo::Helpers do
  it { should include(SinatraMore::OutputHelpers) }
  it { should include(SinatraMore::TagHelpers) }
  it { should include(SinatraMore::AssetTagHelpers) }
  it { should include(SinatraMore::FormHelpers) }
  it { should include(SinatraMore::FormatHelpers) }
  
  let(:helpers) { Object.new.extend(Massimo::Helpers) }
  
  describe '#render' do
    it 'should render a view with the given locals' do
      with_file 'views/partial.haml', '= local' do
        helpers.render('partial', :local => 'Local').should == "Local\n"
      end
    end
  end
  
  describe '#site' do
    it 'should return the current site instance' do
      site = Massimo::Site.new
      helpers.site.should === site
    end
  end
end