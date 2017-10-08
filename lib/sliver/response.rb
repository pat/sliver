# frozen_string_literal: true

class Sliver::Response
  attr_accessor :status, :headers, :body

  def initialize
    @headers = {}
  end

  def to_a
    [status, headers, body]
  end
end
