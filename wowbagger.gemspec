# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wowbagger/version'

Gem::Specification.new do |spec|
  spec.name          = "wowbagger"
  spec.version       = Wowbagger::VERSION
  spec.authors       = ["Steve Huff"]
  spec.email         = ["steve.huff@runkeeper.com"]

  spec.summary       = %q{Take inventory of your AWS resources}
  spec.description   = %q{Wowbagger is a framework and CLI app that enumerates your AWS resources and groups them according to rules you define.}
  spec.homepage      = "https://rubygems.com/gems/wowbagger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

end
