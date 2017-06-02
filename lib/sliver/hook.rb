class Sliver::Hook
  def self.call(action, response)
    new(action, response).call
  end

  def initialize(action, response)
    @action, @response = action, response
  end

  private

  attr_reader :action, :response
end
