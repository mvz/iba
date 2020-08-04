# frozen_string_literal: true

require "rake/file_list"

Gem::Specification.new do |s|
  s.name = "iba"
  s.version = "0.0.5"
  s.summary = "Introspective Block Assertions"
  s.authors = ["Matijs van Zuijlen"]
  s.email = ["matijs@matijs.net"]
  s.homepage = "http://www.github.com/mvz/iba"

  s.required_ruby_version = ">= 2.5.0"

  s.license = "LGPL-3.0+"

  s.description = <<~DESC
    Asserts blocks, prints introspective failure messages.
  DESC

  s.files =
    Rake::FileList["{lib,test,tasks}/**/*",
                   "COPYING.LESSER", "LICENSE", "*.rdoc", "Rakefile"]
    .exclude(*File.read(".gitignore").split)

  s.rdoc_options = ["--main", "README.rdoc"]

  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "COPYING.LESSER"]
  s.test_files = `git ls-files -z -- test`.split("\0")

  s.add_development_dependency("rake", ["~> 13.0"])
  s.add_development_dependency("test-unit", ["~> 3.1"])

  s.require_paths = ["lib"]
end
