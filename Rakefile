# frozen_string_literal: true

require "rake/clean"
require "bundler/gem_tasks"
require "rake/testtask"
require "rake/manifest/task"

namespace :test do
  Rake::TestTask.new(:run) do |t|
    t.libs = ["lib"]
    t.test_files = FileList["test/**/*_test.rb"]
    t.ruby_opts += ["-w"]
  end
end

Rake::Manifest::Task.new do |t|
  t.patterns = ["lib/**/*", "COPYING.LESSER", "LICENSE", "*.rdoc"]
end

desc "Alias to test:run"
task test: "test:run"

task build: "manifest:check"

task default: "test:run"
