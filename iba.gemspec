# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = "iba"
  s.version = "0.0.5"

  s.summary = "Introspective Block Assertions"
  s.description = "Asserts blocks, prints introspective failure messages."
  s.required_ruby_version = ">= 2.4.0"

  s.authors = ["Matijs van Zuijlen"]
  s.email = ["matijs@matijs.net"]
  s.homepage = "http://www.github.com/mvz/iba"

  s.license = "LGPL-3"

  s.rdoc_options = ["--main", "README.rdoc"]

  s.files = Dir["{lib,test,tasks}/**/*",
                "COPYING.LESSER",
                "LICENSE",
                "*.rdoc",
                "Rakefile"] & `git ls-files -z`.split("\0")
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "COPYING.LESSER"]
  s.test_files = `git ls-files -z -- test`.split("\0")

  s.add_development_dependency("rake", ["~> 13.0"])
  s.add_development_dependency("test-unit", ["~> 3.1"])

  s.require_paths = ["lib"]
end
