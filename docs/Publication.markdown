{file:docs/Home.markdown} > **{file:docs/Publication.markdow}**

Publication(Information about EPUB book)
========================================

EPUB Publications is information about EPUB books.

EPUB Parser represents it as {EPUB::Publication} module and classes under the namespace and you can access them such like `EPUB::Parser.parse("path/to/book.epub").package`

Let

    book = EPUB::Parser.parse("path/to/book.epub")

for continuing.

Five Models
-----------

`book.package` is a package document, a root of information tree about the book, and it has attributes to access five major models of the publication; {EPUB::Publication::Package::Metadata Metadata}, {EPUB::Publication::Package::Manifest Manifest}, {EPUB::Publication::Package::Spine Spine}, {EPUB::Publication::Package::Guide Guide} and {EPUB::Publication::Package::Bindings Bindings}.

Each of them has information the book in the way its own.

Metadata
--------

{EPUB::Publication::Package::Metadata Metadata} is literally metadata of the book, including identifiers, titles, languages, links and so on.

You can access them by:

    md = book.package.metadata # => EPUB::Publication::Package::Metadata
    md.titles # => [#<EPUB::Publication::Package::Metadata::Title...>, #<EPUB::Publication::Package::Metadata::Title...>, ...]
    # ...

Manifest
--------

{EPUB::Publication::Package::Manifest Manifest} lists all the files in the package with some basic information such as filepath, media type and so on. Those files is represented as {EPUB::Publication::Package::Manifest::Item Item}s and see {file:docs/Item.markdown} for details.

You can access manifest by:

    manifest = book.package.manifest # => EPUB::Publication::Package::Manifest

And can access items it manages via some methods:

    manifest.items # => an array of Items
    manifest.cover_image # => Item which represents cover images, which includes the string "cover-image" in its property attribute.
    manifest.each_item do |item|
      # do something with item
    end
    manifest.navs # => an array of Items which include the string "nav" in its property attribute.
    manifest.nav # => The first Item in manifest.navs.

For complete list of methods, see API reference: {EPUB::Publication::Package::Manifest}

Spine
-----

Guide
-----

Bindings
--------

Package
-------

References
----------

* [EPUB Publications 3.0][publications] on IDPF site

[publications]: http://www.idpf.org/epub/30/spec/epub30-publications.html
