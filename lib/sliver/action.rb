module Sliver::Action
  def self.included(base)
    base.extend Sliver::Action::ClassMethods
  end

  module ClassMethods
    def call(environment)
      response = Sliver::Response.new
      new(environment, response).call

      response.to_a
    end
  end

  def initialize(environment, response)
    @environment, @response = environment, response
  end

  private

  attr_reader :environment, :response
end
