{file:docs/Home.markdown} > **{file:docs/FixedLayout.markdow}**

Fixed-Layout Documents
======================

Since v0.1.4, EPUB Parser supports Fixed-Layout Documents by {EPUB::Publication::FixedLayout} module.
It is set "on" when `rendition` property exists in `prefix` attribute of `package` element in rootfile.

EPUB Fixed-Layout defines some additional properties to see how to render Content Documents. This EPUB Parser library supports it by providing convenience methods to know how to render.

Methods for {EPUB::Publication::Package}
----------------------------------------

### {EPUB::Publication::FixedLayout::PackageMixin#using_fixed_layout #using_fixed_layout}

It is `true` when `package@prefix` attribute has `rendition` property.

    parser = EPUB::Parser::Publication.new(<<OPF, 'dummy/rootfile.opf')
    <package version="3.0"
             unique-identifier="pub-id"
             xmlns="http://www.idpf.org/2007/opf"
             prefix="rendition: http://www.idpf.org/vocab/rendition/#">
    </package>
    OPF
    package = parser.parse_package
    package.using_fixed_layout # => true

And you can set by yourself:

    package.using_fixed_layout = true
    package.prefix # => {"rendition"=>"http://www.idpf.org/vocab/rendition/#"}

Common Methods
--------------

Methods below are provided for

* {EPUB::Publication::Package::Metadata},
* {EPUB::Publication::Package::Spine::Itemref},
* {EPUB::Publication::Package::Manifest::Item} and
* {EPUB::ContentDocument::XHTML}(and its subclasses).

### #rendition_layout, #rendition_orientation and #rendition_spread

`rendition:xxx` property is specified by `meta` elements in `/package/metadata` and `properties` attribute of `/package/spine/itemref` elements in EPUB Publications. You are recommended to use `rendition_xxx` attribute to set them although you can do it by manipulating {EPUB::Publication::Package::Metadata} and {EPUB::Publication::Package::Spine::Itemref}s directly. It is the reason why it is recommended that you must manipulate some objects not only one object to set a document's `rendition:layout` to, for instance, `reflowable`; {EPUB::Publication::Package::Metadata::Meta Metadata::Meta} and {EPUB::Publication::Package::Spine::Itemref#properties Spine::Itemref#properties}. It is bothered and tends to be mistaken, so you're strongly recommended to use not them but `rendition_layout`.

Usage is simple. Just read and write attribute values.

    metadata.rendition_layout # => "reflowable"
    metadata.rendition_layout = 'pre-paginated'
    metadata.rendition_layout # => "pre-paginated"
    
    itemref.rendition_layout # => "pre-paginated"
    itemref.rendition_layout = "reflowable"
    itemref.rendition_layout # => "reflowable"

These methods are defined for {EPUB::Publication::Package::Metadata}, {EPUB::Publication::Package::Spine::Itemref}, {EPUB::Publication::Package::Manifest::Item} and {EPUB::ContentDocument::XHTML}. Methods for {EPUB::Publication::Package::Metadata Metadata} and {EPUB::Publication::Package::Spine::Itemref Itemref} are primary and ones for {EPUB::Publication::Package::Manifest::Item Item} and {EPUB::ContentDocument::XHTML ContentDocument} are simply delegated to {EPUB::Publication::Package::Spine::Itemref Itemref}.

### aliases

Each attribute `rendition_xxx` has alias attribute as just `xxx`.

    metadata.orientation = 'portrait'
    metadata.orientation # => "portrait"
    metadata.rendition_orientation # => "portrait"

### #reflowable? and #pre_paginated?

Predicate methods `#reflowable?` and `#pre_paginated?` which are shortcuts for comparison `rendition_layout` to arbitrary property value.

    itemref.rendition_layout = 'pre-paginated'
    itemref.reflowable? # => false
    itemref.pre_paginated? # => true

### #make_reflowable and make_pre_paginated

`#make_reflowable`(alias: `#reflowable!`) and `#make_pre_paginated`(alias: `#pre_paginated!`) can be used instead of calling `rendition_layout` and comparing it with `String` `"reflowable"` or `"pre-paginated"`, they help you from mistyping such like `"pre_paginated"`(using underscore rather than hyphen).

Methods for {EPUB::Publication::Package::Spine::Itemref}
--------------------------------------------------------

### #page_spread

{EPUB::Publication::FixedLayout FixedLayout} module adds property `center` to {EPUB::Publication::Package::Spine::Itemref#page_spread}'s available properties, which are ever `left` and `right`.

    itemref.page_spread # => nil
    itemref.page_spread = 'center'
    itemref.page_spread # => "center"
    itemref.properties # => ["rendition:page-spread-center"]

References
----------

* [Fixed-Layout Documents][fixed-layout] on IDPF site

[fixed-layout]: http://www.idpf.org/epub/fxl/
