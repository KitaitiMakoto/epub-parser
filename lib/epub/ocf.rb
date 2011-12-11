%w[container encryption manifest metadata rights signatures].each do |feature|
  require "epub/ocf/#{feature}"
end

module EPUB
  module OCF
  end
end
