if RUBY_VERSION < "2.0.0"
  warn "Ruby version under the 2.0.0 is deprecated."
end

require 'epub/inspector'
require 'epub/ocf'
require 'epub/publication'
require 'epub/content_document'
require 'epub/book/features'
