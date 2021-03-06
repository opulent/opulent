# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opulent/version'

Gem::Specification.new do |spec|
  spec.name          = "opulent"
  spec.version       = Opulent::VERSION
  spec.authors       = ["Alex Grozav"]
  spec.email         = ["alex@grozav.com"]

  spec.summary       = %q{Template Engine for Creative Web Developers}
  spec.description   = %q{Opulent is a templating engine which strives to make page markup as beautiful and expressive as it should be. It's blazing fast, offers useful reusable component definitions and encourages well organised front end code. Opulent provides the cleanliness, readability and development speed you need for your project.}
  spec.homepage      = "http://opulent.io"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = ['opulent']
  spec.require_paths = ["lib"]

  # This gem will work with 2.1.0 or greater...
  spec.required_ruby_version = '>= 2.1.0'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency 'escape_utils'
  spec.add_runtime_dependency 'tilt', '>= 1.3.0'
end
