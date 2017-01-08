Encoding.default_external = 'UTF-8'
require 'simplecov'
SimpleCov.start do
  add_filter '/test|deps/'
end

require 'pp'
require 'test/unit'
require 'test/unit/rr'
require 'test/unit/notify'
require 'pry'
require 'pretty_backtrace'
PrettyBacktrace.enable

require 'epub/parser'
