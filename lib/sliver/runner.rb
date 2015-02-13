class Sliver::Runner
  def initialize(klass, environment)
    @klass, @environment = klass, environment
  end

  def call
    guard_classes.each do |guard_class|
      guard = guard_class.new(action)
      return guard.response unless guard.continue?
    end

    action.call unless action.skip?

    response.to_a
  end

  private

  attr_reader :klass, :environment

  def action
    @action ||= klass.new environment, response
  end

  def guard_classes
    klass.guards
  end

  def response
    @response ||= Sliver::Response.new
  end
end
