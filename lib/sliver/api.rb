class Sliver::API
  NOT_FOUND = lambda { |environment| [404, {}, ['Not Found']] }

  def initialize(&block)
    @endpoints = Hash.new { |hash, key| hash[key] = Sliver::Endpoints.new }

    block.call self
  end

  def call(environment)
    method   = environment['REQUEST_METHOD']
    path     = environment['PATH_INFO']
    endpoint = endpoints[method].find(path)

    endpoint.nil? ? NOT_FOUND.call(environment) : invoke(endpoint, environment)
  end

  def invoke(endpoint, environment)
    endpoint.call environment
  end

  def connect(method, path, action)
    method = method.to_s.upcase

    endpoints[method].append path, action
  end

  private

  attr_reader :endpoints
end
