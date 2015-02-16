class Sliver::API
  NOT_FOUND = lambda { |environment| [404, {}, ['Not Found']] }

  def initialize(&block)
    @endpoints = Sliver::Endpoints.new

    block.call self
  end

  def call(environment)
    endpoint = endpoints.find environment

    endpoint.nil? ? NOT_FOUND.call(environment) : invoke(endpoint, environment)
  end

  def invoke(endpoint, environment)
    endpoint.call environment
  end

  def connect(method, path, action)
    endpoints.append Sliver::Path.new(method, path), action
  end

  private

  attr_reader :endpoints
end
