module EPUB
  class OCF
    MODULES = %w[container encryption manifest metadata rights signatures]
    MODULES.each {|m| require "epub/ocf/#{m}"}

    attr_accessor :book, *MODULES
  end
end
