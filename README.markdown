EPUB Parser
===========
[![Build Status](https://secure.travis-ci.org/KitaitiMakoto/epub-parser.png?branch=master)](http://travis-ci.org/KitaitiMakoto/epub-parser)

INSTALLATION
-------

    gem install epub-parser  

USAGE
-----

### As a library

    require 'epub/parser'
    
    book = EPUB::Parser.parse('book.epub')
    book.each_page_on_spine do |page|
      # do somethong...
    end

See files in docs directory or [API Documentation][rubydoc] for more info.

[rubydoc]: http://rubydoc.info/gems/epub-parser/frames

### `epubinfo` command-line tool

`epubinfo` tool extracts and shows the metadata of specified EPUB book.

    epubinfo path/to/book.epub

For more info:

    epubinfo -h

### `epub-open` command-line tool

`epub-open` tool provides interactive shell(IRB) which helps you research about EPUB book.

    epub-open path/to/book.epub

IRB starts. `self` becomes the EPUB book and can access to methods of `EPUB`.

    title
    => "Title of the book"
    metadata.creators
    => [Author 1, Author2, ...]
    resources.first.properties
    => ["nav"] # You know that first resource of this book is nav document
    nav = resources.first
    => ...
    nav.href
    => #<Addressable::URI:0x15ce350 URI:nav.xhtml>
    nav.media_type
    => "application/xhtml+xml"
    puts nav.read
    <?xml version="1.0"?>
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
        :
        :
        :
    </html>
    => nil
    exit # Enter "exit" when exit the session

For command-line options:

    epub-open -h

Development of this tool is still in progress.
Welcome comments and suggestions for this!

REQUIREMENTS
------------
* libxml2 and libxslt for Nokogiri gem
* C compiler to compile Zip/Ruby and Nokogiri

RECENT CHANGES
--------------
### 0.1.4
* [Fixed-Layout Documents][fixed-layout] support
* Define `ContentDocument::XHTML#top_level?`
* Define `Spine::Itemref#page_spread` and `#page_spread=`
* Define some utility methods around `Manifest::Item` and `Spine::Itemref`

[fixed-layout]: http://www.idpf.org/epub/fxl/

### 0.1.3
* Add a command-line tool `epub-open`
* Add support for XHTML Navigation Document
* Make `EPUB::Publication::Package::Metadata#to_hash` obsolete. Use `#to_h` instead
* Add utility methods `EPUB#description`, `EPUB#date` and `EPUB#unique_identifier`

### 0.1.2
* Fix a bug that `Item#read` couldn't read file when `href` is percent-encoded(Thanks, [gambhiro][]!)

[gambhiro]: https://github.com/gambhiro

### 0.1.1
* Parse package@prefix and attach it as `Package#prefix`
* `Manifest::Item#iri` was removed. `#href` now returns `Addressable::URI` object.
* `Metadata::Link#iri`: ditto.
* `Guide::Reference#iri`: ditto.

See CHANGELOG.markdown for details.

TODOS
-----
* Simple inspect for `epub-open` tool
* Help features for `epub-open` tool
* Vocabulary Association Mechanisms
* Implementing navigation document and so on
* Media Overlays
* Content Document
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
