# frozen_string_literal: true

require "spec_helper"

class GetAction
  include Sliver::Action

  def call
    response.status  = 200
    response.headers = {"Content-Type" => "text/plain"}
    response.body    = ["foo"]
  end
end

class EchoAction
  include Sliver::Action

  def call
    response.status = 200
    response.body   = environment["rack.input"].read
  end
end

class AdditionAction
  include Sliver::Action

  def call
    response.status = 200
    response.body   = [(request.params["a"].to_i + request.params["b"].to_i)]
  end
end

class SkippedAction
  include Sliver::Action

  def skip?
    response.status = 400
    response.body   = ["Invalid"]
  end

  def call
    response.status = 200
    response.body   = ["Success"]
  end
end

class MyParamGuard < Sliver::Hook
  def continue?
    action.request.params["hello"] == "world"
  end

  def respond
    response.status = 404
    response.body   = ["Not Found"]
  end
end

class GuardedAction
  include Sliver::Action

  def self.guards
    [MyParamGuard]
  end

  def call
    response.status = 200
    response.body   = ["Welcome"]
  end
end

class UnguardedAction < GuardedAction
  def self.guards
    super - [MyParamGuard]
  end
end

class IdAction
  include Sliver::Action

  def call
    response.status = 200
    response.body = [path_params["id"]]
  end
end

class MultiPathPartAction
  include Sliver::Action

  def call
    response.status = 200
    response.body = ["#{path_params["first"]}:#{path_params["second"]}"]
  end
end

class JsonProcessor < Sliver::Hook
  def call
    response.headers["Content-Type"] = "application/json"
  end
end

class ProcessedAction
  include Sliver::Action

  def self.processors
    [JsonProcessor]
  end

  def call
    response.status = 200
    response.body   = ["[]"]
  end
end

describe "Class-based Sliver API" do
  include Rack::Test::Methods

  let(:app) do
    Sliver::API.new do |api|
      api.connect :get, "/",         GetAction
      api.connect :put, "/echo",     EchoAction
      api.connect :get, "/addition", AdditionAction
      api.connect :get, "/skip",     SkippedAction
      api.connect :get, "/guard",    GuardedAction
      api.connect :get, "/unguard",  UnguardedAction
      api.connect :get, "/my/:id",   IdAction
      api.connect :get, "/my/:first/:second", MultiPathPartAction
      api.connect :get, "/processed", ProcessedAction
    end
  end

  it "constructs responses" do
    get "/"

    expect(last_response.status).to eq(200)
    expect(last_response.headers["Content-Type"]).to eq("text/plain")
    expect(last_response.body).to eq("foo")
  end

  it "allows use of environment" do
    put "/echo", "baz"

    expect(last_response.body).to eq("baz")
  end

  it "allows use of request" do
    get "/addition", "a" => "5", "b" => "3"

    expect(last_response.body).to eq("8")
  end

  it "allows standard responses to be skipped" do
    get "/skip"

    expect(last_response.status).to eq(400)
    expect(last_response.body).to eq("Invalid")
  end

  it "blocks guarded actions if they cannot continue" do
    get "/guard"

    expect(last_response.status).to eq(404)
    expect(last_response.body).to eq("Not Found")
  end

  it "accepts guarded actions that meet criteria" do
    get "/guard", "hello" => "world"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("Welcome")
  end

  it "respects subclass guard changes" do
    get "/unguard"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("Welcome")
  end

  it "handles path parameter markers" do
    get "/my/10"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("10")
  end

  it "handles path parameters with full stops" do
    get "/my/10.1"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("10.1")
  end

  it "handles path parameters with pluses" do
    get "/my/10+1"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("10+1")
  end

  it "handles multiple path parameter markers" do
    get "/my/10/foo"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("10:foo")
  end

  it "handles processors" do
    get "/processed"

    expect(last_response.status).to eq(200)
    expect(last_response.headers["Content-Type"]).to eq("application/json")
  end
end
