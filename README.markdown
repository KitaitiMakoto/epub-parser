EPUB Parer
==========

INSTALL
-------
    gem install epub-parser  

USAGE
-----
    book = EPUB::Parser.parse 'book.epub', 'working_directory'
    book.each_page_by_spine do |page|
      # do somethong...
    end

See [Wiki](https://gitorious.org/epub/pages) for more info.

REQUIREMENTS
------------
* UNIX like `zip` command
* libxml2 and libxslt for Nokogiri gem

LICENSE
-------
This library is distribuetd under the term of the MIT License.
See MIT-LICENSE file for more info.