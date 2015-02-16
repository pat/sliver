class Sliver::Endpoints
  def initialize
    @paths = {}
  end

  def append(path, action)
    paths[path] = action
  end

  def find(environment)
    key = paths.keys.detect { |key| key.matches?(environment) }
    return nil unless key

    environment['sliver.path'] = key
    paths[key]
  end

  private

  attr_reader :paths
end
