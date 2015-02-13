module Sliver::Action
  def self.included(base)
    base.extend Sliver::Action::ClassMethods
  end

  module ClassMethods
    def call(environment)
      response = Sliver::Response.new

      action = new(environment, response)

      guards.each do |guard_class|
        guard = guard_class.new(action)
        return guard.response unless guard.continue?
      end

      action.call unless action.skip?

      response.to_a
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
end
