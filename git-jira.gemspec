# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git-jira/version'

Gem::Specification.new do |spec|
  spec.name          = "git-jira"
  spec.version       = GitJira::VERSION
  spec.authors       = ["rob hurring"]
  spec.email         = ["rob.hurring@lendkey.com"]
  spec.summary       = %q{Git command for dealing with Jira}
  spec.description   = %q{Git commands for git-jira workflow}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 1.6"
  spec.add_dependency "rake"
  spec.add_dependency "thor", "~> 0.19.1"
  spec.add_dependency "httparty", ">= 0.11.0"
  spec.add_dependency "netrc", "~> 0.7.7"
end
