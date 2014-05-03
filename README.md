# Sliver

A super simple, extendable Rack API.

## Installation

Add it to your Gemfile like any other gem, or install it manually yourself.

```ruby
gem 'sliver', '~> 0.0.1'
```

## Usage

Create a new API (a Rack app, of course), and specify paths with corresponding
responses. Responses can be anything that responds to `call` with a single
argument (the request environment) and returns a standard Rack response (an
array with three items: status code, headers, and body).

So, a response can be as simple as a lambda/proc, or it can be a complex class.
If you want to deal with classes, you can mix in `Sliver::Action` to take
advantage of some helper methods (and it already stores environment via
`attr_reader`), and it returns a `Sliver::Response` class which is translated to
the standard Rack response. Each instance of a class that mixes in
`Sliver::Action` is handling a specific API request.

```ruby
app = Sliver::API.new do |api|
  # All API endpoints are namespaced by a version.
  api.version = 'v1'

  # GET /v1/
  api.connect :get, '/', lambda { |environment|
    [200, {}, ['How dare the Premier ignore my invitations?']]
  }

  # PUT /v1/change
  api.connect :put, '/change', ChangeAction
end

class ChangeAction
  include Sliver::Action

  def call
    # Change the status:
    response.status = 404

    # Add to the response headers:
    response.headers['Content-Type'] = 'text/plain'

    # Add a response body - let's provide an array, like Rack expects:
    response.body = [
      "How dare the Premier ignore my invitations?",
      "He'll have to go",
      "So, to the bunch he luncheons with",
      "It's second on my list of things to do"
    ]

    # Access the request environment:
    self.environment

    # Access to a Rack::Request object built from that environment:
    self.request
  end
end
```

If you want all responses to API requests to share some behaviour - say, for
example, you are always returning JSON - then you can create your own base class
for this purpose:

```ruby
class JSONAction
  include Sliver::Action

  def call
    response.headers['Content-Type'] = 'application/json'
    response.body = [JSON.generate(response.body)]
  end
end

class ChangeAction < JSONAction
  def call
    response.status = 200
    response.body   = {'status' => 'OK'}

    super
  end
end
```

## Contributing

1. Fork it ( https://github.com/pat/sliver/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request