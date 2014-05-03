class Sliver::API
  def initialize(&block)
    @endpoints = {}

    block.call self
  end

  def call(environment)
    method   = environment['REQUEST_METHOD']
    path     = environment['PATH_INFO']
    endpoint = endpoints[method][path]

    endpoint.call environment
  end

  def get(path, action)
    endpoints['GET']     ||= {}
    endpoints['GET'][path] = action
  end

  private

  attr_reader :endpoints
end
