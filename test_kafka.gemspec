# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'test_kafka/version'

Gem::Specification.new do |spec|
  spec.name          = "test_kafka"
  spec.version       = TestKafka::VERSION
  spec.authors       = ["Brian Schroeder"]
  spec.email         = ["bts@gmail.com"]
  spec.description   = %q{Minimal Kafka runner suitable for integration testing}
  spec.summary       = spec.description
  spec.homepage      = "http://github.com/bts/test_kafka"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1.0"
  spec.add_development_dependency "rspec", "~> 2.12.0"

  spec.add_dependency "daemon_controller", "~> 1.0.0"
end
