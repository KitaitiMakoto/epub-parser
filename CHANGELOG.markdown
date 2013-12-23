CHANGELOG
=========
0.1.6
-----
* Remove `EPUB.parse` method
* Remove `EPUB::Publication::Package::Metadata#to_hash`
* Add `EPUB::Publication::Package::Metadata::Identifier` for ad-hoc `scheme` attribute and `#isbn?` method
* Remove `MethodDecorators::Deprecated`
* Make `EPUB::Parser::OCF::CONTAINER_FILE` and other constants deprecated

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
