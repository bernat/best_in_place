# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'best_in_place/version'

Gem::Specification.new do |s|
  s.name        = "best_in_place"
  s.version     = BestInPlace::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bernat Farrero"]
  s.email       = ["bernat@itnig.net"]
  s.homepage    = "http://github.com/bernat/best_in_place"
  s.summary     = <<SUM
  It makes any field in place editable by clicking on it, it works for inputs,
  textareas, select dropdowns and checkboxes
SUM
  s.description = <<DESC
  BestInPlace is a jQuery script and a Rails helper that provide the method best_in_place to display
  any object field easily editable for the user by just clicking on it. It supports input data,
  text data, boolean data and custom dropdown data. It works with RESTful controllers.
DESC

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'actionpack', '>= 3.2'
  s.add_runtime_dependency 'rails_autosize_jquery', '3.0.15'
  s.add_runtime_dependency 'railties', '>= 3.2'

end
