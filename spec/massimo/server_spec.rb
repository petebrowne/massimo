require 'spec_helper'

describe Massimo::Server do
  let(:app) { Massimo::Server.new(Massimo.site) }
  
  it 'serves up static files' do
    with_file 'public/stylesheets/main.css', 'body { font-size: 12px; }' do
      get '/stylesheets/main.css'
      last_response.body.should == 'body { font-size: 12px; }'
    end
  end
  
  it 'serves up directory index files' do
    with_file 'public/about-us/index.html', 'About Us' do
      get '/about-us/'
      last_response.body.should == 'About Us'
    end
  end
  
  context 'when files have changed' do
    it 'processes the site on request' do
      with_file 'pages/index.haml' do
        mock(Massimo.site).process
        get '/'
      end
    end
  end
  
  context 'when files have not changed' do
    it 'does not process the site on request' do
      with_file 'pages/index.haml' do
        mock(Massimo.site).process
        get '/'
        dont_allow(Massimo.site).process
        get '/'
      end
    end
  end
end