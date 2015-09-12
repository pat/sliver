# Sliver

A super simple, extendable Rack API.

[![Build Status](https://travis-ci.org/pat/sliver.svg?branch=master)](https://travis-ci.org/pat/sliver)
[![Code Climate](https://codeclimate.com/github/pat/sliver.png)](https://codeclimate.com/github/pat/sliver)
[![Gem Version](https://badge.fury.io/rb/sliver.svg)](http://badge.fury.io/rb/sliver)

## Why?

Ruby doesn't lack for web frameworks, especially ones focused on APIs, but Sliver is a little different from others I've come across.

* It focuses on one class per endpoint, for increased Single Responsibility Principle friendliness.
* Separate classes allows for better code organisation, instead of everything in one file.
* It's a pretty small layer on top of Rack, which is the only dependency, which keeps things light and fast.
* Guards and processors provide some structures for managing authentication, JSON responses and other common behaviours across actions (similar to Rails before_action filters).

## Installation

Add it to your Gemfile like any other gem, or install it manually.

```ruby
gem 'sliver', '~> 0.2.2'
```

## Usage

At its most basic level, Sliver is a simple routing engine to other Rack endpoints. You can map out a bunch of routes (with the HTTP method and the path), and the corresponding endpoints for requests that come in on those routes.

### Lambda Endpoints

Here's an example using lambdas, where the responses must match Rack's expected output (an array with three items: status code, headers, and body).

```ruby
app = Sliver::API.new do |api|
  api.connect :get, '/', lambda { |environment|
    [200, {}, ['How dare the Premier ignore my invitations?']]
  }

  api.connect :post '/hits', lambda { |environment|
    HitMachine.create! Rack::Request.new(environment).params[:hit]

    [200, {}, ["He'll have to go!"]]
  }
end
```

### Sliver::Action Endpoints

However, it can be nice to encapsulate each endpoint in its own class - to keep responsibilities clean and concise. Sliver provides a module `Sliver::Action` which makes this approach reasonably simple, with helper methods to the Rack environment and a `response` object, which can have `status`, `headers` and `body` set (which is automatically translated into the Rack response).

```ruby
app = Sliver::API.new do |api|
  api.connect :get, '/changes', ChangesAction
end

class ChangesAction
  include Sliver::Action

  def call
    # This isn't a realistic implementation - just examples of how
    # to interact with the provided variables.

    # Change the status:
    response.status = 404

    # Add to the response headers:
    response.headers['Content-Type'] = 'text/plain'

    # Add a response body - let's provide an array, like Rack expects:
    response.body = [
      "How dare the Premier ignore my invitations?",
      "He'll have to go",
      "So too the bunch he luncheons with",
      "It's second on my list of things to do"
    ]

    # Access the request environment:
    self.environment

    # Access to a Rack::Request object built from that environment:
    self.request
  end
end
```

### Path Parameters

Much like Rails, you can have named parameters in your paths, which are available via `path_params` within your endpoint behaviour:

```ruby
app = Sliver::API.new do |api|
  api.connect :get, '/changes/:id', ChangeAction
end

class ChangeAction
  include Sliver::Action

  def call
    change = Change.find path_params['id']

    response.status = 200
    response.body   = ["Change: #{change.name}"]
  end
end
```

It's worth noting that unlike Rails, these values are not mixed into the standard `params` hash.

### Guards

Sometimes you're going to have endpoints where you want to check certain things before getting into the core implementation: one example could be to check whether the request is made by an authenticated user. In Sliver, you can do this via Guards:

```ruby
app = Sliver::API.new do |api|
  api.connect :get, '/changes/:id', ChangeAction
end

class ChangeAction
  include Sliver::Action

  def self.guards
    [AuthenticatedUserGuard]
  end

  def call
    change = Change.find path_params['id']

    response.status = 200
    response.body   = ["Change: #{change.name}"]
  end

  def user
    @user ||= User.find_by :key => request.env['Authentication']
  end
end

class AuthenticatedUserGuard < Sliver::Hook
  def continue?
    action.user.present?
  end

  def respond
    response.status = 401
    response.body   = ['Unauthorised: valid session is required']
  end
end
```

Guards inheriting from `Sliver::Hook` just need to respond to `call`, and have access to `action` (your endpoint instance) and `response` (which will be turned into a proper Rack response).

They are set in the action via a class method (which must return an array of classes), and a guard instance must respond to two methods: `continue?` and `respond`. If `continue?` returns true, then the main action `call` method is used. Otherwise, it's skipped, and the guard's `respond` method needs to set the alternative response.

### Processors

Processors are behaviours that happen after the endpoint logic has been performed. These are particularly useful for transforming the response, perhaps to JSON if your API is expected to always return JSON:

```ruby
app = Sliver::API.new do |api|
  api.connect :get, '/changes/:id', ChangeAction
end

class ChangeAction
  include Sliver::Action

  def self.processors
    [JSONProcessor]
  end

  def call
    change = Change.find path_params['id']

    response.status = 200
    response.body   = {:id => change.id, :name => change.name}
  end
end

class JSONProcessor < Sliver::Hook
  def call
    response.body                    = [JSON.generate(response.body)]
    response.headers['Content-Type'] = 'application/json'
  end
end
```

Processors inheriting from `Sliver::Hook` just need to respond to `call`, and have access to `action` (your endpoint instance) and `response` (which will be turned into a proper Rack response).

### Testing

Because your API is a Rack app, it can be tested using `rack-test`'s helper methods. Here's a quick example for RSpec:

```ruby
describe 'My API' do
  include Rack::Test::Methods

  let(:app) { MyApi.new }

  it 'responds to GET requests' do
    get '/'

    expect(last_response.status).to eq(200)
    expect(last_response.headers['Content-Type']).to eq('text/plain')
    expect(last_response.body).to eq('foo')
  end
end
```

### Running via config.ru

It's pretty easy to run your Sliver API via a `config.ru` file:

```ruby
require 'rubygems'
require 'bundler'

Bundler.setup :default
$:.unshift File.dirname(__FILE__) + '/lib'

require 'my_app'

run MyApp::API.new
```

### Running via Rails

Of course, you can also run your API within the context of Rails by mounting it in your `config/routes.rb` file:

```ruby
MyRailsApp::Application.routes.draw do
  mount Api::V1.new => '/api/v1'
end
```

There is also the [sliver-rails](https://github.com/pat/sliver-rails) gem which adds some nice extensions to Sliver with Rails in mind.

## Contributing

Please note that this project now has a [Contributor Code of Conduct](http://contributor-covenant.org/version/1/0/0/). By participating in this project you agree to abide by its terms.

1. Fork it ( https://github.com/pat/sliver/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Licence

Copyright (c) 2014-2015, Sliver is developed and maintained by Pat Allan, and is
released under the open MIT Licence.
