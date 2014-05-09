module Sliver::Action
  def self.included(base)
    base.extend Sliver::Action::ClassMethods
  end

  module ClassMethods
    def call(environment)
      response = Sliver::Response.new

      action = new(environment, response)
      action.call unless action.skip?

      response.to_a
    end
  end

  def initialize(environment, response)
    @environment, @response = environment, response
  end

  def skip?
    false
  end

  private

  attr_reader :environment, :response

  def request
    @request ||= Rack::Request.new environment
  end
end
