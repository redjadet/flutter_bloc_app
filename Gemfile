source 'https://rubygems.org'

# jwt CVE-2026-45363 needs >= 3.2.0; faraday CVE-2026-54297 needs >= 2.14.3.
# Rubygems fastlane 2.236.x still pins faraday ~> 1.0 — use faraday-2 branch from
# fastlane/fastlane#30089 until a release ships, then revert to a pinned gem version.
gem 'fastlane', github: 'fastlane/fastlane', ref: 'e856f9df9bd470f41e87d4a5fec424580f7230c8'
gem 'jwt', '~> 3.2'
gem 'faraday', '>= 2.14.3'
