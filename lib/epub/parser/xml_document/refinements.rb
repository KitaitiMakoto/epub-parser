require "epub/parser/xml_document/refinements/rexml"
begin
  require "epub/parser/xml_document/refinements/nokogiri"
  EPUB::Parser::XMLDocument.backend = :Nokogiri
rescue LoadError
  EPUB::Parser::XMLDocument.backend = :REXML
end
