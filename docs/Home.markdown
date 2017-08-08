EPUB Parser
===========

EPUB Parser gem parses EPUB 3 book loosely.

Installation
------------

    gem install epub-parser

Usage
-----

### As command-line tools

#### epubinfo

`epubinfo` tool extracts and shows the metadata of specified EPUB book.

See {file:docs/Epubinfo}.

#### epub-open

`epub-open` tool provides interactive shell(IRB) which helps you research about EPUB book.

See {file:docs/EpubOpen}.

### As a library

Use `EPUB::Parser.parse` at first:

    require 'epub/parser'
    
    book = EPUB::Parser.parse('/path/to/book.epub')

This book object can yield page by spine's order(spine defines the order to read that the author determines):

    book.each_page_on_spine do |page|
      # do something...
    end

`page` above is an {EPUB::Publication::Package::Manifest::Item} object and you can call {EPUB::Publication::Package::Manifest::Item#href #href} to see where is the page file:

    book.each_page_on_spine do |page|
      file = page.href # => path/to/page/in/zip/archive
      html = Zip::Archive.open('/path/to/book.epub') {|zip|
        zip.fopen(file.to_s) {|file| file.read}
      }
    end

And {EPUB::Publication::Package::Manifest::Item Item} provides syntax suger {EPUB::Publication::Package::Manifest::Item#read #read} for above:

    html = page.read
    doc = Nokogiri.HTML(html)
    # do something with Nokogiri as always

For several utilities of Item, see {file:docs/Item.markdown} page.

By the way, although `book` above is a {EPUB::Book} object, all features are provided by {EPUB::Book::Features} module. Therefore YourBook class can include the features of {EPUB::Book::Features}:

    require 'epub'
    
    class YourBook < ActiveRecord::Base
        include EPUB::Book::Features
    end
    
    book = EPUB::Parser.parse(
      'uploaded-book.epub',
      :class => YourBook # *************** pass YourBook class
    )
    book.instance_of? YourBook # => true
    book.required = 'value for required field'
    book.save!
    book.each_page_on_spine do |epage|
      page = YouBookPage.create(
        :some_attr    => 'some attr',
        :content      => epage.read,
        :another_attr => 'another attr'
      )
      book.pages << page
    end

You are also able to find YourBook object for the first:

    book = YourBook.find params[:id]
    ret = EPUB::Parser.parse(
      'uploaded-book.epub',
      :book => book # ******************* pass your book instance
    ) # => book
    ret == book # => true; this API is not good I feel... Welcome suggestion!
    # do something with your book

Documentation
-------------

More documentations are avaiable in:

* {file:docs/Publication.markdown}
* {file:docs/Item.markdown}
* {file:docs/FixedLayout.markdown}
* {file:docs/Navigation.markdown}
* {file:docs/Searcher.markdown}
* {file:docs/UnpackedArchive.markdown}
* {file:docs/AggregateContentsFromWeb.markdown}
* {file:docs/MultipleRenditions.markdown}

If you installed EPUB Parser via gem command, you can also generate documentaiton by your own([rubygems-yardoc][] gem is needed):

    $ gem install epub-parser
    $ gem yardoc epub-parser
    ...
    Files:          33
    Modules:        20 (   20 undocumented)
    Classes:        45 (   44 undocumented)
    Constants:      31 (   31 undocumented)
    Methods:       292 (   88 undocumented)
    52.84% documented
    YARD documentation is generated to:
    /path/to/gempath/ruby/2.2.0/doc/epub-parser-0.2.0/yardoc

It will show you path to generated documentation(`/path/to/gempath/ruby/2.2.0/doc/epub-parser-0.2.0/yardoc` here) at the end.

Or, generating yardoc command is possible, too:

    $ git clone https://gitlab.com/KitaitiMakoto/epub-parser.git
    $ cd epub-parser
    $ bundle install --path=deps
    $ bundle exec rake doc:yard
    ...
    Files:          33
    Modules:        20 (   20 undocumented)
    Classes:        45 (   44 undocumented)
    Constants:      31 (   31 undocumented)
    Methods:       292 (   88 undocumented)
    52.84% documented

Then documentation will be available in `doc` directory.

[homepage]: http://www.rubydoc.info/gems/epub-parser/file/docs/Home.markdown
[rubygems-yardoc]: https://rubygems.org/gems/rubygems-yardoc

Requirements
------------

* Ruby 2.2.0 or later
* C compiler to compile Zip/Ruby and Nokogiri

Note
----

This library is still in work.
Only a few features are implemented and APIs might be changed in the future.
Note that.

Currently implemented:

* container.xml of [EPUB Open Container Format (OCF) 3.0][]
* [EPUB Publications 3.0][]
* EPUB Navigation Documents of [EPUB Content Documents 3.0][]
* [EPUB 3 Fixed-Layout Documents][]
* metadata.xml of [EPUB Multiple-Rendition Publications][]

[EPUB Open Container Format (OCF) 3.0]:http://idpf.org/epub/30/spec/epub30-ocf.html#sec-container-metainf-container.xml
[EPUB Publications 3.0]:http://idpf.org/epub/30/spec/epub30-publications.html
[EPUB Content Documents 3.0]:http://www.idpf.org/epub/30/spec/epub30-contentdocs.html
[EPUB 3 Fixed-Layout Documents]:http://www.idpf.org/epub/fxl/
[EPUB Multiple-Rendition Publications]: http://www.idpf.org/epub/renditions/multiple/

License
-------

This library is distributed under the term of the MIT Licence.
See {file:MIT-LICENSE} file for more info.
