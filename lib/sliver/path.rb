class Sliver::Path
  def initialize(string)
    @string = string
  end

  def matches?(path)
    string.is_a?(String) ? (string == path) : path[/\A#{string}\z/]
  end

  private

  attr_reader :string
end
