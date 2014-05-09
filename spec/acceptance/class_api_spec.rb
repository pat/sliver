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

class AdditionAction
  include Sliver::Action

  def call
    response.status = 200
    response.body   = [(request.params['a'].to_i + request.params['b'].to_i)]
  end
end

class SkippedAction
  include Sliver::Action

  def skip?
    response.status = 400
    response.body   = ['Invalid']
  end

  def call
    response.status = 200
    response.body   = ['Success']
  end
end

describe 'Class-based Sliver API' do
  include Rack::Test::Methods

  let(:app) { Sliver::API.new do |api|
    api.connect :get, '/',         GetAction
    api.connect :put, '/echo',     EchoAction
    api.connect :get, '/addition', AdditionAction
    api.connect :get, '/skip',     SkippedAction
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

  it 'allows use of request' do
    get '/addition', 'a' => '5', 'b' => '3'

    expect(last_response.body).to eq('8')
  end

  it 'allows standard responses to be skipped' do
    get '/skip'

    expect(last_response.status).to eq(400)
    expect(last_response.body).to eq('Invalid')
  end
end
