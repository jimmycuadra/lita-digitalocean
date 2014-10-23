Gem::Specification.new do |spec|
  spec.name          = "lita-digitalocean"
  spec.version       = "2.0.0"
  spec.authors       = ["Jimmy Cuadra"]
  spec.email         = ["jimmy@jimmycuadra.com"]
  spec.description   = %q{A Lita handler for managing DigitalOcean services.}
  spec.summary       = %q{A Lita handler for managing DigitalOcean services.}
  spec.homepage      = "https://github.com/jimmycuadra/lita-digitalocean"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.0"
  spec.add_runtime_dependency "lita-keyword-arguments"
  spec.add_runtime_dependency "digital_ocean", ">= 1.5.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
