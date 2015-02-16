module Sliver::Action
  def self.included(base)
    base.extend Sliver::Action::ClassMethods
  end

  module ClassMethods
    def call(environment)
      Sliver::Runner.new(self, environment).call
    end

    def guards
      []
    end
  end

  def initialize(environment, response)
    @environment, @response = environment, response
  end

  def request
    @request ||= Rack::Request.new environment
  end

  def skip?
    false
  end

  private

  attr_reader :environment, :response

  def path_params
    @path_params ||= environment['sliver.path'].to_params environment
  end
end
