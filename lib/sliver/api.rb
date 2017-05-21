class Sliver::API
  NOT_FOUND_RESPONSE = [404, {'X-Cascade' => 'pass'}, ['Not Found']].freeze
  NOT_FOUND = lambda { |environment| NOT_FOUND_RESPONSE }

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
