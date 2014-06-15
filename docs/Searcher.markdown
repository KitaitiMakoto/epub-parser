{file:docs/Home.markdown} > **{file:docs/Searcher.markdown}**

Searcher
========

*Searcher is experimental now. Note that all interfaces are not stable at all.*

Example
-------

    epub = EPUB::Parser.parse('childrens-literature-20130206.epub')
    search_word = 'INTRODUCTORY'
    results = EPUB::Searcher.search(epub.package, search_word)
    # => [#<EPUB::Searcher::Result:0x007f74d2b31548
    #   @end_steps=[#<EPUB::Searcher::Result::Step:0x007f74d2b7baa8 @index=12, @type=:character>],
    #   @parent_steps=
    #    [#<EPUB::Searcher::Result::Step:0x007f74d2b81318 @index=2, @name="spine", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b7f4c8 @index=1, @type=:itemref>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b7d560 @index=1, @name="body", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b7d308 @index=0, @name="nav", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b7cdb8 @index=1, @name="ol", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b7cb38 @index=0, @name="li", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b7c5e8 @index=1, @name="ol", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b7bf80 @index=1, @name="li", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b7bd28 @index=0, @name="a", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b7bb70 @index=0, @type=:text>],
    #   @start_steps=[#<EPUB::Searcher::Result::Step:0x007f74d2b7baf8 @index=0, @type=:character>]>,
    #  #<EPUB::Searcher::Result:0x007f74d294e258
    #   @end_steps=[#<EPUB::Searcher::Result::Step:0x007f74d2b0f8d0 @index=12, @type=:character>],
    #   @parent_steps=
    #    [#<EPUB::Searcher::Result::Step:0x007f74d2b81318 @index=2, @name="spine", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b314f8 @index=2, @type=:itemref>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b2fb80 @index=1, @name="body", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b2f900 @index=0, @name="section", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b10578 @index=3, @name="section", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b0fb50 @index=1, @name="h3", @type=:element>,
    #     # #<EPUB::Searcher::Result::Step:0x007f74d2b0f998 @index=0, @type=:text>],
    #   @start_steps=[#<EPUB::Searcher::Result::Step:0x007f74d2b0f920 @index=0, @type=:character>]>]
    puts results.collect(&:to_cfi_s)
    # /6/4!/4/2/4/2/4/4/2/1,:0,:12
    # /6/6!/4/2/8/4/1,:0,:12
    # => nil

Search result
-------------

Search result is an array of {EPUB::Searcher::Result} and it may be converted to an EPUBCFI string by {EPUB::Searcher::Result#to_cfi_s}.

Restricted XHTML Searcher
-------------------------

Now searcher for XHTML documents is *restricted*, which means that it can search from only single elements. For instance, it can find 'search word' from XHTML document below:

    <html>
      <head>
        <title>Sample document</title>
      </head>
      <body>
        <p>search word</p>
      </body>
    </html>

But cannot from document below:

    <html>
      <head>
        <title>Sample document</title>
      </head>
      <body>
        <p><em>search</em> word</p>
      </body>
    </html>

because the words 'search' and 'word' are not in the same element.
