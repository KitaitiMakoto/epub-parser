CHANGELOG
=========

0.2.3
-----

* Change the name of physical container adapter for file system: :File -> :UnpackedDirectory
* Add `EPUB::Publication::Package::Manifest::Item#full_path`

0.2.2
-----

* [BUGFIX]Item#entry_name returns normalized IRI

0.2.1
-----

* Remove deprecated `EPUB::Constants::MediaType::UnsupportedError`. Use `UnsupportedMediatType` instead.
* Make it possible to use [archive-zip][] gem to extract contents from EPUB package via `EPUB::OCF::PhysicalContainer::ArchiveZip`
* Add warning about default physical container adapter change
* Make it possible to extract contents from the web via `EPUB::OCF::PhysicalContainer::UnpackedURI`. See {file:ExtractContentsFromWeb.markdown} for details.

[archive-zip]: https://github.com/javanthropus/archive-zip

0.2.0
-----

* Introduce abstraction layer for OCF physical container
* Add `EPUB::OCF::PhysicalContainer::File` and make it possible to parse file system directory as an EPUB file. See {file:docs/UnpackedArchive.markdown} for details.
* Remove `EPUB::Parser::OCF::CONTAINER_FILE` and other constants

0.1.9
-----

* Introduce [Nokogumbo][] for XHTML Content Documents
* Stop support for Ruby 1.9
* Remove `EPUB.included` method. Now including `EPUB` module empowers nothing of EPUB features. Include `EPUB::Book::Features` instead.
* Add `EPUB::Searcher::XHTML::Seamless` and make it default searcher
* Add `EPUB::Publication::Package::Manifest#each_nav`
* Stop to use enumerabler gem

[nokogumbo]: https://github.com/rubys/nokogumbo/

0.1.8
-----

* Explicity #close each zip member file that has been opened via #fopen(Thanks, [xunker][]!)

[xunker]: https://github.com/xunker

0.1.7.1
-------

* Don't set encoding when content is not text

0.1.7
-----

* [Experimental]Add `EPUB::Searcher` module. See {file:Searcher.markdown} for details
* Detect and set character encoding in `EPUB::Publication::Package::Item#read`

0.1.6
-----
* Remove `EPUB.parse` method
* Remove `EPUB::Publication::Package::Metadata#to_hash`
* Add `EPUB::Publication::Package::Metadata::Identifier` for ad-hoc `scheme` attribute and `#isbn?` method
* Remove `MethodDecorators::Deprecated`
* Make `EPUB::Parser::OCF::CONTAINER_FILE` and other constants deprecated
* Make `EPUB::Publication::Package::Metadata::Link#rel` a `Set`
* Add exception class `EPUB::Constants::MediaType::UnsupportedMediaType`
* Make `EPUB::Constants::MediaType::UnsupportedError` deprecated. Use `UnsupportedMediatType` instead
* Add `EPUB::Publication::Package::Item#cover_image?`
* Add `EPUB::Book::Features` module and move methods of `EPUB` module to it(Thanks, [takahashim][]!)
* Make including `EPUB` deprecated
* Parse `hidden` attribute of `nav` elements
* [Experimental]Add `EPUB::ContentDocument::Navigation::Item#traverse`

[takahashim]: https://github.com/takahashim

0.1.5
-----
* Add `ContentDocument::XHTML#title`
* Add `Manifest::Item#xhtml?`
* Add `--words` and `--chars` options to `epubinfo` command which count words and charactors of XHTMLs in EPUB file
* API change: `OCF::Container::Rootfile#full_path` became Addressable::URI object rather than `String`. `EPUB#rootfile_path` still returns `String`
* Add `ContentDocument::XHTML#rexml` which returns document as `REXML::Document` object
* Add `ContentDocument::XHTML#nokogiri` which returns document as `Nokogiri::XML::Document` object
* Inspect more readbly

0.1.4
-----
* [Fixed-Layout Documents][fixed-layout] support
* Define `ContentDocument::XHTML#top_level?`
* Define `Spine::Itemref#page_spread` and `#page_spread=`
* Define some utility methods around `Manifest::Item` and `Spine::Itemref`
  * `Manifest::Item#itemref`
  * `Spine::Itemref#item=`

[fixed-layout]: http://www.idpf.org/epub/fxl/

0.1.3
-----
* Add `EPUB::Parser::Utils` module
* Add a command-line tool `epub-open`
* Add support for XHTML Navigation Document
* Make `EPUB::Publication::Package::Metadata#to_hash` obsolete. Use `#to_h` instead
* Add utility methods `EPUB#description`, `EPUB#date` and `EPUB#unique_identifier`

0.1.2
-----
* Fix a bug that `Item#read` couldn't read file when `href` is percent-encoded(Thanks, [gambhiro][]!)

[gambhiro]: https://github.com/gambhiro

0.1.1
-----
* Parse package@prefix and attach it as `Package#prefix`
* `Manifest::Item#iri` was removed. It have existed for files in unzipped epub books but now EPUB Parser retrieves files from zip archive directly. `#href` now returns `Addressable::URI` object.
* `Metadata::Link#iri`: ditto.
* `Guide::Reference#iri`: ditto.
