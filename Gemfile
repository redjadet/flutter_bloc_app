source 'https://rubygems.org'

# jwt CVE-2026-45363 needs >= 3.2.0; faraday CVE-2026-54297 needs >= 2.14.3.
# Rubygems fastlane 2.236.x still pins faraday ~> 1.0 — use faraday-2 branch from
# fastlane/fastlane#30089 until a release ships, then revert to a pinned gem version.
gem 'fastlane', github: 'fastlane/fastlane', ref: '2ed5e781d60f9d54ab96f8e4cea9501f1e3d9e21'
gem 'jwt', '~> 3.2'
gem 'faraday', '>= 2.14.3'
