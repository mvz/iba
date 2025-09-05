# frozen_string_literal: true

require_relative "lib/iba/version"

Gem::Specification.new do |spec|
  spec.name = "iba"
  spec.version = Iba::VERSION
  spec.authors = ["Matijs van Zuijlen"]
  spec.email = ["matijs@matijs.net"]

  spec.summary = "Introspective Block Assertions"
  spec.description = <<~DESC
    Asserts blocks, prints introspective failure messages.
  DESC
  spec.homepage = "http://www.github.com/mvz/iba"

  spec.license = "LGPL-3.0+"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mvz/iba"
  spec.metadata["changelog_uri"] = "https://github.com/mvz/iba/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = File.read("Manifest.txt").split
  spec.require_paths = ["lib"]

  spec.rdoc_options = ["--main", "README.md"]
  spec.extra_rdoc_files = ["README.md", "LICENSE", "COPYING.LESSER"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-manifest", "~> 0.2.0"
  spec.add_development_dependency "rubocop", "~> 1.52"
  spec.add_development_dependency "rubocop-packaging", "~> 0.6.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.18"
  spec.add_development_dependency "test-unit", "~> 3.1"
end
