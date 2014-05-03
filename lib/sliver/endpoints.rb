class Sliver::Endpoints
  def initialize
    @paths = {}
  end

  def append(path, action)
    @paths[path] = action
  end

  def find(path)
    @paths[path]
  end
end
