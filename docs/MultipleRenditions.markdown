{file:docs/Home.markdown} > **{file:docs/MultipleRenditions.markdown}**

Multiple Renditions
===================

An EPUB publication(file) may have multiple renditions, how reading system renders contents. It is expressed as multiple {EPUB::Publication::Package} object.

Usually, you don't need to care about it.

    epub = EPUB::Parser.parse('path/to/book')
    epub.package # => #<EPUB::Publication::Package...>

This is enough in most cases.

Getting multiple renditions
---------------------------

If your book has multiple renditions, you can get them by {EPUB::Book::Features#packages}, aliased as {EPUB::Book::Features#packages #renditoins}.

    epub.packages # => [#<EPUB::Publication::Package...>, #<EPUB::Publication::Package...>, ...]

`epub.package` is shortcut to `epub.packages.first`(called default rendition).

    epub.package == epub.packages.first # => true
    epub.default_rendition == epub.packages.first # => true

Metadata of renditions
----------------------

Sometimes, the situation about metadata is more complicated.

A publication may have multiple rendition(package)s. A rendition has a metadata. So, A publication has as many metadata objects as renditions...

    epub.packages.all? {|package| package.respond_to? :metadata} # => true

... at least.

In addition, a publication may have a metadata that is not related to any rendition but to EPUB file itself. You can access to it by:

    epub.ocf.metadata # => #<EPUB::Metadata...>

This kind of metadata is introduced by [EPUB Multiple-Rendition Publications][] spec and most EPUB files don't have that for now. So, you need to note that `epub.ocf.metadata` might be `nil`.

Identifiers
-----------

You can identify any metadata by identifers called release identifier. If your book has metadata for publication and packages, they might not have the same identifier to any identifiers of renditions. By this difference, publishers or authors can represent the situation "all renditions are changed but the book itself is not." To do so, publishers or authors will change all identifiers of renditions(`epub.packages.collect(&:metadata).collect(&:release_identifier)`) but keep `epub.ocf.metadata.release_identifier`.

Known issues
------------

Currently, at least on v0.2.6, EPUB Parser provides limited support for [Multiple-Rendition][EPUB Multiple-Rendition Publications] spec.

See also
--------

* [EPUB Publications 3.0.1][]
* [EPUB Multiple-Rendition Publications][]

[EPUB Publications 3.0.1]: http://www.idpf.org/epub/301/spec/epub-publications.html
[EPUB Multiple-Rendition Publications]: http://www.idpf.org/epub/renditions/multiple/
