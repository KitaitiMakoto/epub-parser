# coding: utf-8
# Preparation
#
#   % cd examples
#   % wget -O accessible-epub3.epub 'https://drive.google.com/uc?export=download&id=0B9g8D2Y-6aPLRmFKRTNIam93RTQ'
#
# Execution
#
#   % ruby exctract-content-using-cfi.rb accessible-epub3.epub '/6/10!/4/2/4'
#   <p>Accessibility is a difficult concept to define. There’s no single magic bullet
#   				solution that will make all content accessible to all people. Perhaps that’s a
#   				strange way to preface a book on accessible practices, but it’s also a reality you
#   				need to be aware of. Accessible practices change, technologies evolve to solve
#   				stubborn problems, and the world becomes a more accessible place all the time.</p>
#
#   % ruby exctract-content-using-cfi.rb accessible-epub3.epub '/6/10!/4/2,/4,/8'
#   <p>Accessibility is a difficult concept to define. There’s no single magic bullet
#   				solution that will make all content accessible to all people. Perhaps that’s a
#   				strange way to preface a book on accessible practices, but it’s also a reality you
#   				need to be aware of. Accessible practices change, technologies evolve to solve
#   				stubborn problems, and the world becomes a more accessible place all the time.</p>
#   				                                                                         <p xmlns="http://www.w3.org/1999/xhtml">But although there are best practices that everyone should be following, and that
#   				will be detailed as we go along, this guide should neither be read as an instrument
#   				for accessibility compliance nor as a replacement for existing guidelines.</p>
#   				<p></p>
#
# Yes, output above shows a bug!
#
#   % ruby exctract-content-using-cfi.rb accessible-epub3.epub '/6/10!/4/2/4,:0,:47'
#   Accessibility is a difficult concept to define.

require 'epub/parser'
require 'epub/cfi'
require 'nokogiri' # Do gem install nokogiri
require 'nokogiri/xml/range' # Do gem install nokogiri-xml-range

def main(argv)
  epub_path = argv.shift
  cfi_string = argv.shift
  if epub_path.nil? or cfi_string.nil?
    $stderr.puts "USAGE: ruby #{$0} EPUB CFI"
    abort
  end

  epub = EPUB::Parser.parse(epub_path)
  cfi = EPUB::CFI(cfi_string)

  content = extract_content(epub, cfi)
  case content
  when Nokogiri::XML::Element
    puts content
  when Nokogiri::XML::Range
    puts content.clone_contents
  end
end

def extract_content(epub, cfi)
  if cfi.kind_of? EPUB::CFI::Location
    node = get_element(cfi, epub)
    offset = cfi.paths.last.offset
    offset = offset.value if offset
    # Maybe offset may not be used
    return node
  end

  start_node = get_element(cfi.first, epub)
  # Need more consideration
  start_node = start_node.children.first if start_node.element?

  end_node = get_element(cfi.last, epub)
  # Need more consideration
  end_node = end_node.children.last if end_node.element?

  start_offset = cfi.first.paths.last.offset
  start_offset = start_offset ? start_offset.value : 0
  end_offset = cfi.last.paths.last.offset
  end_offset = end_offset ? end_offset.value : 0

  range = Nokogiri::XML::Range.new(start_node, start_offset, end_node, end_offset)

  return range
end

def get_element(cfi, epub)
  path_in_package = cfi.paths.first
  step_to_itemref = path_in_package.steps[1]
  itemref = epub.spine.itemrefs[step_to_itemref.step / 2 - 1]

  doc = itemref.item.content_document.nokogiri
  path_in_doc = cfi.paths[1]
  current_node = doc.root
  path_in_doc.steps.each do |step|
    if step.element?
      current_node = current_node.element_children[step.value / 2 - 1]
    else
      element_index = (step.value - 1) / 2 - 1
      if element_index == -1
        current_node = current_node.children.first
      else
        prev = current_node.element_children[element_index]
        break unless prev
        current_node = prev.next_sibling
        break unless current_node
      end
    end
  end

  current_node
end

main(ARGV)
