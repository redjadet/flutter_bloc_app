source 'https://rubygems.org'

# jwt CVE-2026-45363 needs >= 3.2.0. Rubygems fastlane 2.234.0 still caps jwt < 3;
# use commit from fastlane/fastlane#30042 until 2.235.0 ships, then revert to
# gem 'fastlane', '2.235.0' (or current).
gem 'fastlane', github: 'fastlane/fastlane', ref: 'e931cf55279c14fa6514f7f605be0ec7adac2460'
gem 'jwt', '~> 3.2'
