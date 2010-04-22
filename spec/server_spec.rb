require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Server do
  let(:app) { Massimo::Server.new(Massimo.site) }
  
  it 'should serve up static files' do
    within_construct do |c|
      c.file 'public/stylesheets/main.css', 'body { font-size: 12px; }'
      get '/stylesheets/main.css'
      last_response.body.should == 'body { font-size: 12px; }'
    end
  end
  
  it 'should serve up directory index files' do
    within_construct do |c|
      c.file 'public/about-us/index.html', 'About Us'
      get '/about-us/'
      last_response.body.should == 'About Us'
    end
  end
  
  context 'when files have changed' do
    it 'should process the site on request' do
      within_construct do |c|
        c.file 'pages/index.haml'
        mock(Massimo.site).process
        get '/'
      end
    end
  end
  
  context 'when files have not changed' do
    it 'should not process the site on request' do
      within_construct do |c|
        dont_allow(Massimo.site).process
        get '/'
      end
    end
  end
end
