source 'https://rubygems.org'

# jwt CVE-2026-45363 needs >= 3.2.0; faraday CVE-2026-54297 needs >= 2.14.3.
# Rubygems fastlane 2.236.x still pins faraday ~> 1.0 — use faraday-2 branch from
# fastlane/fastlane#30089 until a release ships, then revert to a pinned gem version.
gem 'fastlane', github: 'fastlane/fastlane', ref: '0eeb05a35744e3e67c23bd43c743f95dc7c7d727'
gem 'jwt', '~> 3.3', '>= 3.3.1'
gem 'faraday', '>= 2.15.0'
