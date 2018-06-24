# frozen_string_literal: true

require_relative "lib/keybase/local"

Gem::Specification.new do |s|
  s.name                  = "keybase-unofficial-local"
  s.version               = Keybase::Local::VERSION
  s.summary               = "keybase-unofficial-local - Unofficial library for Keybase clients"
  s.description           = <<~DESCRIPTION
                              This library provides access to Keybase's desktop utility from
                              Ruby.
                            DESCRIPTION
  s.authors               = ["William Woodruff"]
  s.email                 = "william@tuffbizz.com"
  s.files                 = Dir["LICENSE", "*.md", ".yardopts", "lib/**/*"]
  s.required_ruby_version = ">= 2.3.0"
  s.homepage              = "https://github.com/kbsecret/keybase-unofficial-local"
  s.license               = "MIT"

  s.add_runtime_dependency "keybase-unofficial-core", "~> 1.0"
  s.add_runtime_dependency "sys-filesystem", "~> 1.1"
end
