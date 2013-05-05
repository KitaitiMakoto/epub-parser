{file:docs/Home} > **{file:docs/EpubOpen}**

`epub-open` command-line tool
=============================

`epub-open` tool provides interactive shell(IRB) which helps you research about EPUB book.

Usage
-----

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

