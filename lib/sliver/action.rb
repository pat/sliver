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

    def processors
      []
    end
  end

  def initialize(environment, response)
    @environment = environment
    @response    = response
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
    @path_params ||= environment[Sliver::PATH_KEY].to_params environment
  end
end
