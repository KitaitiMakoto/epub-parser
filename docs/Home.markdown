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
        zip.fopen(file.to_s).read
      }
    end

And {EPUB::Publication::Package::Manifest::Item Item} provides syntax suger {EPUB::Publication::Package::Manifest::Item#read #read} for above:

    html = page.read
    doc = Nokogiri.HTML(html)
    # do something with Nokogiri as always

For several utilities of Item, see {file:docs/Item.markdown} page.

By the way, although `book` above is a {EPUB::Book} object, all features are provided by {EPUB} module. Therefore YourBook class can include the features of {EPUB}:

    require 'epub'
    
    class YourBook < ActiveRecord::Base
        include EPUB
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

More documentations are avaiable in:

* {file:docs/Item.markdown}
* {file:docs/FixedLayout.markdown}

Requirements
------------

* libxml2 and libxslt for Nokogiri gem
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

[EPUB Open Container Format (OCF) 3.0]:http://idpf.org/epub/30/spec/epub30-ocf.html#sec-container-metainf-container.xml
[EPUB Publications 3.0]:http://idpf.org/epub/30/spec/epub30-publications.html
[EPUB Content Documents 3.0]:http://www.idpf.org/epub/30/spec/epub30-contentdocs.html
[EPUB 3 Fixed-Layout Documents]:http://www.idpf.org/epub/fxl/

License
-------

This library is distributed under the term of the MIT Licence.
See {file:MIT-LICENSE} file for more info.
