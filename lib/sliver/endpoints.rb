class Sliver::Endpoints
  def initialize
    @paths = {}
  end

  def append(path, action)
    paths[path] = action
  end

  def find(environment)
    path = paths.keys.detect { |key| key.matches?(environment) }
    return nil unless path

    environment[Sliver::PATH_KEY] = path
    paths[path]
  end

  private

  attr_reader :paths
end
