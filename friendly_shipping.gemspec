# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "friendly_shipping/version"

Gem::Specification.new do |spec|
  spec.name          = "friendly_shipping"
  spec.version       = FriendlyShipping::VERSION
  spec.authors       = ["Martin Meyerhoff"]
  spec.email         = ["mamhoff@gmail.com"]

  spec.summary       = "An integration layer for shipping services"
  spec.description   = "Allows you to quote or ship a Physical::Shipment object"
  spec.homepage      = "https://github.com/friendlycart/friendly_shipping"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "data_uri", ">= 0.0.3", "< 0.2.0"
  spec.add_runtime_dependency "dry-monads", "~> 1.0"
  spec.add_runtime_dependency "money", "~> 6.0"
  spec.add_runtime_dependency "nokogiri", "~> 1.6"
  spec.add_runtime_dependency "physical", "~> 0.4", ">= 0.4.4"
  spec.add_runtime_dependency "rest-client", "~> 2.0"
  spec.required_ruby_version = '>= 2.5'

  spec.add_development_dependency "bundler", ">= 2.1.4", "< 3"
  spec.add_development_dependency "dotenv", "~> 2.7"
  spec.add_development_dependency "factory_bot", "~> 6.2"
  spec.add_development_dependency "pry", "~> 0.12"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.4"
  spec.add_development_dependency "rubocop", ">= 0.80", "< 1"
  spec.add_development_dependency "simplecov", "~> 0.17"
  spec.add_development_dependency "vcr", "~> 5.0"
  spec.add_development_dependency "webmock", "~> 3.6"
end
