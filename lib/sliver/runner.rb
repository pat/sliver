class Sliver::Runner
  def initialize(klass, environment)
    @klass       = klass
    @environment = environment

    @guarded = false
  end

  def call
    pass_guards
    action.call unless skip_action?
    post_process

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

  def guarded?
    @guarded
  end

  def guarded!
    @guarded = true
  end

  def pass_guards
    guard_classes.each do |guard_class|
      guard = guard_class.new action, response
      next if guard.continue?

      guard.respond
      guarded!
      break
    end
  end

  def post_process
    klass.processors.each { |processor| processor.call action, response }
  end

  def response
    @response ||= Sliver::Response.new
  end

  def skip_action?
    guarded? || action.skip?
  end
end
