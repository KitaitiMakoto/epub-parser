Feature: We can see information about EPUB file

Scenario: See info about existing EPUB file
  Given the file "test/fixtures/book.epub" exists
  When I successfully run `bundle exec epubinfo /home/ikeda/ruby/projects/epub-parser/test/fixtures/book.epub`
  Then the stdout should contain "The New French Cuisine Masters"
