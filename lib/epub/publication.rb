%w[ package metadata manifest spine guide ].each { |f| require "epub/publication/#{f}"}

module EPUB
  module Publication
  end
end
