class Sliver::API
  HTTP_METHODS = %w( OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PATCH )
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

  HTTP_METHODS.each do |method|
    define_method method.downcase.to_sym do |path, action|
      endpoints[method]     ||= {}
      endpoints[method][path] = action
    end
  end

  private

  attr_reader :endpoints
end
