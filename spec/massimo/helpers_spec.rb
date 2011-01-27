require 'spec_helper'

describe Massimo::Helpers do
  it { should include(Padrino::Helpers::DomHelpers) }
  it { should include(Padrino::Helpers::OutputHelpers) }
  it { should include(Padrino::Helpers::TagHelpers) }
  it { should include(Padrino::Helpers::AssetTagHelpers) }
  it { should include(Padrino::Helpers::FormHelpers) }
  it { should include(Padrino::Helpers::FormatHelpers) }
  it { should include(Padrino::Helpers::NumberHelpers) }
  it { should include(Padrino::Helpers::TranslationHelpers) }
  
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