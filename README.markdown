EPUB Parser
===========

INSTALL
-------
    gem install epub-parser  

USAGE
-----
    require 'epub/parser'
    
    book = EPUB::Parser.parse 'book.epub', 'working_directory'
    book.each_page_on_spine do |page|
      # do somethong...
    end

See the [wiki][] for more info.

[wiki]:https://gitorious.org/epub/pages/EpubParser

REQUIREMENTS
------------
* UNIX like `unzip` command
* libxml2 and libxslt for Nokogiri gem

LICENSE
-------
This library is distribuetd under the term of the MIT License.
See MIT-LICENSE file for more info.
