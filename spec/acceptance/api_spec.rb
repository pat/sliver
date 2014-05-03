require 'spec_helper'

describe 'Sliver' do
  include Rack::Test::Methods

  let(:app) { Sliver::API.new do |api|
    api.get '/', lambda { |environment|
      [200, {'Content-Type' => 'text/plain'}, ['foo']]
    }

    api.get '/bar', lambda { |environment|
      [200, {'Content-Type' => 'text/plain'}, ['baz']]
    }
  end }

  it 'responds to GET requests' do
    get '/'

    expect(last_response.status).to eq(200)
    expect(last_response.headers['Content-Type']).to eq('text/plain')
    expect(last_response.body).to eq('foo')
  end

  it 'delegates to the appropriate endpoint' do
    get '/bar'

    expect(last_response.body).to eq('baz')
  end
end
