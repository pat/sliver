require 'spec_helper'

describe 'Sliver' do
  include Rack::Test::Methods

  let(:app) { Sliver::API.new do |api|
    api.get '/', lambda { [200, {'Content-Type' => 'text/plan'}, ['foo']]}
  end }

  it 'responds to GET requests' do
    get '/'

    expect(last_response.status).to eq(200)
    expect(last_response.headers['Content-Type']).to eq('text/plain')
    expect(last_response.body).to eq('foo')
  end
end
