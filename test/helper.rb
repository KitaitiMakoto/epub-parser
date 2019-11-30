Encoding.default_external = 'UTF-8'
require 'simplecov'
SimpleCov.start do
  add_filter /test|deps/
end

require 'pp'
require 'test/unit'
require 'test/unit/rr'
require 'test/unit/notify'
require 'pry'
if ENV["PRETTY_BACKTRACE"]
  require 'pretty_backtrace'
  PrettyBacktrace.enable
end

require 'epub/parser'
if ENV["XML_BACKEND"]
  EPUB::Parser::XMLDocument.backend = ENV["XML_BACKEND"].to_sym
end
