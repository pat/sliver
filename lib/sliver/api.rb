class Sliver::API
  NOT_FOUND = lambda { |environment| [404, {}, ['Not Found']] }

  attr_accessor :path

  def initialize(&block)
    @endpoints = {}
    @path      = ''

    block.call self
  end

  def call(environment)
    method    = environment['REQUEST_METHOD']
    path_info = environment['PATH_INFO'].gsub(/\A#{path}/, '')
    endpoint  = endpoints.fetch(method, {}).fetch(path_info, NOT_FOUND)

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
