class Sliver::API
  attr_accessor :path

  def initialize(&block)
    @endpoints = {}
    @path      = ''

    block.call self
  end

  def call(environment)
    method    = environment['REQUEST_METHOD']
    path_info = environment['PATH_INFO'].gsub(/\A#{path}/, '')
    endpoint  = endpoints.fetch(method, {}).fetch(path_info, not_found)

    endpoint.call environment
  end

  def connect(method, path, action)
    method = method.to_s.upcase

    endpoints[method]     ||= {}
    endpoints[method][path] = action
  end

  private

  attr_reader :endpoints

  def not_found
    @not_found ||= lambda { |environment| [404, {}, ['Not Found']] }
  end
end
