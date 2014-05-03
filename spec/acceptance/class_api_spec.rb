require 'spec_helper'

class GetAction
  include Sliver::Action

  def call
    response.status  = 200
    response.headers = {'Content-Type' => 'text/plain'}
    response.body    = ['foo']
  end
end

class EchoAction
  include Sliver::Action

  def call
    response.status = 200
    response.body   = environment['rack.input'].read
  end
end

describe 'Class-based Sliver API' do
  include Rack::Test::Methods

  let(:app) { Sliver::API.new do |api|
    api.connect :get, '/',     GetAction
    api.connect :put, '/echo', EchoAction
  end }

  it 'constructs responses' do
    get '/'

    expect(last_response.status).to eq(200)
    expect(last_response.headers['Content-Type']).to eq('text/plain')
    expect(last_response.body).to eq('foo')
  end

  it 'allows use of environment' do
    put '/echo', 'baz'

    expect(last_response.body).to eq('baz')
  end
end
