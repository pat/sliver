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

  def connect(method, path, action)
    method = method.to_s.upcase

    endpoints[method]     ||= {}
    endpoints[method][path] = action
  end

  private

  attr_reader :endpoints
end
