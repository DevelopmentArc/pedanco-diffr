require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
Bundler.setup

require 'pedanco/diffr' # and any other gems you need

RSpec.configure do |_config|
  # some (optional) config here
end
