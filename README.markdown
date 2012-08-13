EPUB Parser
===========

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

See the [wiki][] for more info.

[wiki]:https://github.com/KitaitiMakoto/epub-parser/wiki

REQUIREMENTS
------------
* UNIX like `unzip` command
* libxml2 and libxslt for Nokogiri gem

TODOS
-----
* Adding tests
* Implementing navigation document and so on
* Using SAX on parsing
* Extracting and organizing common behavior from some classes to modules
* Abstraction of XML parser(making it possible to use REXML, standard bundled XML library of Ruby)

DONE
----
* Using zip library instead of `unzip` command, which has security issue

LICENSE
-------
This library is distribuetd under the term of the MIT License.
See MIT-LICENSE file for more info.
