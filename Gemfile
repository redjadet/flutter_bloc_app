source 'https://rubygems.org'

# jwt CVE-2026-45363 needs >= 3.2.0. Rubygems fastlane 2.234.0 still caps jwt < 3;
# use commit from fastlane/fastlane#30042 until 2.235.0 ships, then revert to
# gem 'fastlane', '2.235.0' (or current).
gem 'fastlane', github: 'fastlane/fastlane', ref: '4a6c792778e901a6756a96fa52962a6bc2ede90d'
gem 'jwt', '~> 3.2'
