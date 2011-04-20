# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "push_it/version"

Gem::Specification.new do |s|
  s.name        = "pushit"
  s.version     = PushIt::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Noah Davis", "Bryan Helmkamp"]
  s.email       = ["noah.box@gmail.com", "bryan@brynary.com"]
  s.homepage    = ""
  s.summary     = "REST deploy service"
  s.description = "Runs deploys from a remote, centralized server"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency "sinatra", "~> 1.2.3"

  s.require_paths = ["lib"]
end
