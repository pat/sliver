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

class MyParamGuard
  def initialize(action)
    @action = action
  end

  def continue?
    action.request.params['hello'] == 'world'
  end

  def response
    [404, {}, ['Not Found']]
  end

  private

  attr_reader :action
end

class GuardedAction
  include Sliver::Action

  def self.guards
    [MyParamGuard]
  end

  def call
    response.status = 200
    response.body   = ['Welcome']
  end
end

class UnguardedAction < GuardedAction
  def self.guards
    super - [MyParamGuard]
  end
end

describe 'Class-based Sliver API' do
  include Rack::Test::Methods

  let(:app) { Sliver::API.new do |api|
    api.connect :get, '/',         GetAction
    api.connect :put, '/echo',     EchoAction
    api.connect :get, '/addition', AdditionAction
    api.connect :get, '/skip',     SkippedAction
    api.connect :get, '/guard',    GuardedAction
    api.connect :get, '/unguard',  UnguardedAction
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

  it 'blocks guarded actions if they cannot continue' do
    get '/guard'

    expect(last_response.status).to eq(404)
    expect(last_response.body).to eq('Not Found')
  end

  it 'accepts guarded actions that meet criteria' do
    get '/guard', 'hello' => 'world'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('Welcome')
  end

  it 'respects subclass guard changes' do
    get '/unguard'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('Welcome')
  end
end
