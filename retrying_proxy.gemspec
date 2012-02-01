# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "retrying_proxy/version"

Gem::Specification.new do |s|
  s.name        = "retrying_proxy"
  s.version     = RetryingProxy::VERSION
  s.authors     = ["Christopher J. Bottaro"]
  s.email       = ["cjbottaro@alumni.cs.utexas.edu"]
  s.homepage    = "https://github.com/cjbottaro/retrying_proxy"
  s.summary     = %q{Easily retry methods to deal with transient failures}
  s.description = %q{Implements the proxy pattern retry methods on a class/object}

  s.rubyforge_project = "retrying_proxy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rr"
  # s.add_runtime_dependency "rest-client"
end
