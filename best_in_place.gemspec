# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "best_in_place/version"

Gem::Specification.new do |s|
  s.name        = "best_in_place"
  s.version     = BestInPlace::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bernat Farrero"]
  s.email       = ["bernat@itnig.net"]
  s.homepage    = "http://github.com/bernat/best_in_place"
  s.summary     = %q{It makes any field in place editable by clicking on it, it works for inputs, textareas, select dropdowns and checkboxes}
  s.description = %q{BestInPlace is a jQuery script and a Rails 3 helper that provide the method best_in_place to display any object field easily editable for the user by just clicking on it. It supports input data, text data, boolean data and custom dropdown data. It works with RESTful controllers.}

  s.rubyforge_project = "best_in_place"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "rails", "~> 3.1.0.rc4"
end
