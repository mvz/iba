# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'iba'
  s.version = '0.0.2'

  s.summary = 'Introspective Block Assertions'
  s.description = 'Asserts blocks, prints introspective failure messages.'

  s.authors = ['Matijs van Zuijlen']
  s.email = ['matijs@matijs.net']
  s.homepage = 'http://www.github.com/mvz/iba'

  s.rdoc_options = ['--main', 'README.rdoc']

  s.files = Dir['{lib,test,tasks}/**/*', 'COPYING.*', 'LICENSE', '*.rdoc', 'Rakefile'] &
    `git ls-files -z`.split("\0")
  s.extra_rdoc_files = ['README.rdoc', 'LICENSE', 'COPYING.LESSER', 'COPYING']
  s.test_files = `git ls-files -z -- test`.split("\0")

  s.add_development_dependency('rake', ['~> 10.1'])

  s.require_paths = ['lib']
end
