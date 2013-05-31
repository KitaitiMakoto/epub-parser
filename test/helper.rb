require 'simplecov'
SimpleCov.start do
  add_filter '/test|deps|method_decorators/'
end

require 'test/unit'
require 'test/unit/rr'
require 'test/unit/notify'
require 'epub/parser'
