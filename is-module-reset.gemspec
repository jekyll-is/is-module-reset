# frozen_string_literal: true

require_relative 'lib/is-module-reset/info'

Gem::Specification::new do |s|

  s.name        =   IS::ModuleReset::Info::NAME
  s.version     =   IS::ModuleReset::Info::VERSION
  s.summary     =   IS::ModuleReset::Info::SUMMARY
  s.description =   IS::ModuleReset::Info::SUMMARY + '.'
  s.authors     = [ IS::ModuleReset::Info::AUTHOR   ]
  s.email       = [ IS::ModuleReset::Info::EMAIL    ]
  s.homepage    =   IS::ModuleReset::Info::HOMEPAGE
  s.license     =   IS::ModuleReset::Info::LICENSE

  s.files = Dir[ 'lib/**/*', 'README.md', 'LICENSE' ]

  s.required_ruby_version = '>= 3.4'

  s.add_dependency 'is-deep', '~> 0.8', '>= 0.8.0.4'

  s.add_development_dependency 'rspec',     '~> 3.13'
  s.add_development_dependency 'rake',      '~> 13.3'
  s.add_development_dependency 'simplecov', '~> 1.1'

end
