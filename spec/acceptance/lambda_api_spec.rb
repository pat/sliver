# frozen_string_literal: true

require "spec_helper"

describe "Basic Sliver API" do
  include Rack::Test::Methods

  let(:app) do
    Sliver::API.new do |api|
      api.connect :get, "/", lambda { |_environment|
        [200, {"Content-Type" => "text/plain"}, ["foo"]]
      }

      api.connect :get, "/bar", lambda { |_environment|
        [200, {"Content-Type" => "text/plain"}, ["baz"]]
      }

      api.connect :post, "/", lambda { |_environment|
        [200, {"Content-Type" => "text/plain"}, ["qux"]]
      }

      api.connect :delete, %r{/remove/\d+}, lambda { |_environment|
        [200, {}, ["removed"]]
      }
    end
  end

  it "responds to GET requests" do
    get "/"

    expect(last_response.status).to eq(200)
    expect(last_response.headers["Content-Type"]).to eq("text/plain")
    expect(last_response.body).to eq("foo")
  end

  it "matches empty paths as /" do
    get ""

    expect(last_response.body).to eq("foo")
  end

  it "delegates to the appropriate endpoint" do
    get "/bar"

    expect(last_response.body).to eq("baz")
  end

  it "responds to POST requests" do
    post "/"

    expect(last_response.body).to eq("qux")
  end

  it "responds to unknown endpoints with a 404" do
    get "/missing"

    expect(last_response.status).to eq(404)
    expect(last_response.body).to eq("Not Found")
    expect(last_response.headers["X-Cascade"]).to eq("pass")
  end

  it "matches against regular expressions" do
    delete "/remove/141"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("removed")
  end
end
