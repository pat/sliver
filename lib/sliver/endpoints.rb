class Sliver::Endpoints
  def initialize
    @paths = {}
  end

  def append(path, action)
    path = '/' if path == ''

    paths[path] = action
  end

  def find(path)
    path = '/' if path == ''

    key = paths.keys.detect { |key|
      key.is_a?(String) ? (key == path) : path[/\A#{key}\z/]
    }

    key && paths[key]
  end

  private

  attr_reader :paths
end
