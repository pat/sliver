require 'spec_helper'

describe 'Basic Sliver API' do
  include Rack::Test::Methods

  let(:app) { Sliver::API.new do |api|
    api.connect :get, '/', lambda { |environment|
      [200, {'Content-Type' => 'text/plain'}, ['foo']]
    }

    api.connect :get, '/bar', lambda { |environment|
      [200, {'Content-Type' => 'text/plain'}, ['baz']]
    }

    api.connect :post, '/', lambda { |environment|
      [200, {'Content-Type' => 'text/plain'}, ['qux']]
    }

    api.connect :delete, %r{/remove/\d+}, lambda { |environment|
      [200, {}, ['removed']]
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

  it 'responds to POST requests' do
    post '/'

    expect(last_response.body).to eq('qux')
  end

  it 'responds to unknown endpoints with a 404' do
    get '/missing'

    expect(last_response.status).to eq(404)
    expect(last_response.body).to eq('Not Found')
  end

  it 'matches against regular expressions' do
    delete '/remove/141'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('removed')
  end
end

describe 'Basic lambda API with a path prefix' do
  include Rack::Test::Methods

  let(:app) { Sliver::API.new do |api|
    api.path = '/v1'

    api.connect :get, '/', lambda { |environment|
      [200, {'Content-Type' => 'text/plain'}, ['foo']]
    }
  end }

  it 'responds to GET requests' do
    get '/v1/'

    expect(last_response.body).to eq('foo')
  end
end
