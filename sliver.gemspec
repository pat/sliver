Gem::Specification.new do |spec|
  spec.name          = "sliver"
  spec.version       = "0.2.4"
  spec.authors       = ["Pat Allan"]
  spec.email         = ["pat@freelancing-gods.com"]
  spec.summary       = "Lightweight, simple Rack APIs"
  spec.description   = "A super simple, object-focused extendable Rack API."
  spec.homepage      = "https://github.com/pat/sliver"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rack", ">= 1.5.2"

  spec.add_development_dependency "rack-test", ">= 0.6.2"
  spec.add_development_dependency "rspec",     ">= 3.6.0"
  spec.add_development_dependency "rubocop",   "~> 0.50.0"
end
