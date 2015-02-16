class Sliver::Path
  def initialize(http_method, string)
    @http_method = http_method.to_s.upcase
    @string      = normalised_path string
  end

  def matches?(environment)
    method = environment['REQUEST_METHOD']
    path   = normalised_path environment['PATH_INFO']

    http_method == method && path[string_to_regexp]
  end

  def to_params(environment)
    return {} unless matches?(environment)

    path   = normalised_path environment['PATH_INFO']
    keys   = string.to_s.scan(/:([\w-]+)/i).flatten
    values = path.scan(string_to_regexp).flatten
    hash   = {}

    keys.each_with_index { |key, index| hash[key] = values[index] }
    hash
  end

  private

  attr_reader :http_method, :string

  def normalised_path(string)
    string == '' ? '/' : string
  end

  def string_to_regexp
    @string_to_regexp ||= Regexp.new(
      "\\A" + string.to_s.gsub(/:[\w-]+/, "([\\w-]+)") + "\\z"
    )
  end
end
