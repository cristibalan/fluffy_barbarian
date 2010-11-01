# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fluffy_barbarian/version"

Gem::Specification.new do |s|
  s.name        = "fluffy_barbarian"
  s.version     = FluffyBarbarian::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Cristi Balan"]
  s.email       = ["evil@che.lu"]
  s.homepage    = "http://rubygems.org/gems/fluffy_barbarian"
  s.summary     = %q{Fluffy barbarian carefully handles your blog}
  s.description = s.summary + "!"

  s.rubyforge_project = "fluffy_barbarian"

  fixture_files = Dir["test/fixtures/content/_posts/*.mkd"]
  files = "git ls-files --exclude='test/fixtures/content/_posts/*.mkd'"

  s.files         = `#{files}`.split("\n") + fixture_files
  s.test_files    = `#{files} -- {test,spec,features}/*`.split("\n") + fixture_files
  s.executables   = `#{files} -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "test-spec"

  s.add_dependency "RedCloth"
  s.add_dependency "i18n"
  s.add_dependency "activesupport"
  s.add_dependency "haml"
  s.add_dependency "rack"
  s.add_dependency "rdiscount"
  s.add_dependency "tilt"
end
