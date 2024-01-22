
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "AfricasTalking/version"

Gem::Specification.new do |spec|
  spec.name          = "africastalking-ruby"
  spec.version       = AfricasTalking::VERSION
  spec.authors       = ["Michael Mwirigi"]
  spec.email         = ["mmwirigi@africastalking.com"]

  spec.summary       = "Simple gem that helps you build integrations with AfricasTalking"
  spec.description   = ""
  spec.homepage      = "https://africastalking.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.5.5"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", ">= 6.1.0"
  spec.add_development_dependency "rubocop", ">= 1.60.1"
  spec.add_development_dependency "pry" , "~> 0"
  spec.add_dependency "httparty", ">=0.21.0"
end
