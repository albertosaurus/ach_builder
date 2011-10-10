# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ach/version"

Gem::Specification.new do |s|
  s.name        = "ach_builder"
  s.version     = ACH::VERSION
  s.authors     = ["Artem Kuzko", "Sergey Potapov"]
  s.email       = ["AKuzko@sphereconsultinginc.com", "SPotapov@sphereconsultinginc.com"]
  s.homepage    = "http://github.com/akuzko/ach_builder"
  s.summary     = "Ruby tools for building ACH files"
  s.description = "Ruby tools for building ACH (Automated Clearing House) files"

  #s.rubyforge_project = "ach_builder"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", ">= 2.0.0"
  s.add_runtime_dependency "active_support", ">= 2.3.0"
end
