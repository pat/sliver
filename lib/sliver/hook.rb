class Sliver::Hook
  def initialize(action, response)
    @action, @response = action, response
  end

  private

  attr_reader :action, :response
end
