EPUB Parser
===========
[![Build Status](https://secure.travis-ci.org/KitaitiMakoto/epub-parser.png?branch=master)](http://travis-ci.org/KitaitiMakoto/epub-parser)

INSTALLATION
-------
    gem install epub-parser  

USAGE
-----

### As a command line tool

    epubinfo path/to/book.epub

For more info:

    epubinfo -h

### As a library

    require 'epub/parser'
    
    book = EPUB::Parser.parse 'book.epub'
    book.each_page_on_spine do |page|
      # do somethong...
    end

See the [wiki][] or [API Documentation][rubydoc] for more info.

[wiki]: https://github.com/KitaitiMakoto/epub-parser/wiki
[rubydoc]: http://rubydoc.info/gems/epub-parser/frames

REQUIREMENTS
------------
* libxml2 and libxslt for Nokogiri gem

CHANGELOG
---------

### 0.1.1
* Parse package@prefix and attach it as `Package#prefix`
* `Manifest::Item#iri` wes removed. It have existed for files in unzipped epub books but now EPUB Parser retrieves files from zip archive directly. `#href` now returns `Addressable::URI` object.
* `Metadata::Link#iri`: ditto.
* `Guide::Reference#iri`: ditto.

TODOS
-----
* Vocabulary Association Mechanisms
* Implementing navigation document and so on
* Fixed Layout
* Digital Signature
* Using SAX on parsing
* Extracting and organizing common behavior from some classes to modules
* Abstraction of XML parser(making it possible to use REXML, standard bundled XML library of Ruby)

DONE
----
* Using zip library instead of `unzip` command, which has security issue
* Modify methods around fallback to see `bindings` element in the package

LICENSE
-------
This library is distribuetd under the term of the MIT License.
See MIT-LICENSE file for more info.
