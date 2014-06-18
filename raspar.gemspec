# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "raspar/version"

Gem::Specification.new do |s|
  s.name        = "raspar"
  s.version     = Raspar::VERSION
  s.authors     = ["Jiren Patel"]
  s.email       = ["jiren@joshsoftware.com"]
  s.homepage    = ""
  s.summary     = %q{A generic html/xml parser}
  s.description = %q{Raspar collects data from the html page and creates object from it.}

  s.rubyforge_project = "raspar"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_dependency "nokogiri", ">= 1.5.5"
end
