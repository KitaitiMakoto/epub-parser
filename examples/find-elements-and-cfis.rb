require 'English'
require 'epub/parser'
require 'epub/parser/cfi'
require 'nokogiri'

def usage
  <<EOS

USAGE:
 ruby #{$PROGRAM_NAME} ELEMENT EPUB

EOS
end

def main(argv)
  elem_name = argv.shift
  epub_path = argv.shift
  if elem_name.nil? or epub_path.nil?
    abort usage
  end

  spine_step = EPUB::CFI::Step.new(6)

  epub = EPUB::Parser.parse(epub_path)
  epub.package.spine.each_itemref.with_index do |itemref, i|
    assertion = itemref.id ? EPUB::CFI::IDAssertion.new(itemref.id) : nil
    itemref_step = EPUB::CFI::Step.new((i + 1) * 2, assertion)
    path_to_itemref = EPUB::CFI::Path.new([spine_step, itemref_step])
    itemref.item.content_document.nokogiri.search(elem_name).each do |elem|
      path = find_path(elem)
      location = EPUB::CFI::Location.new([path_to_itemref, path])
      puts
      puts location
      puts elem
    end
  end
end

def find_path(elem)
  steps = []
  until elem.parent.document?
    index = elem.parent.element_children.index(elem)
    assertion = elem["id"] ? EPUB::CFI::IDAssertion.new(elem["id"]) : nil
    steps.unshift EPUB::CFI::Step.new((index + 1) * 2, assertion)
    elem = elem.parent
  end
  EPUB::CFI::Path.new(steps)
end

main ARGV
