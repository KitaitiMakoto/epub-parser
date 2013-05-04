{file:docs/Home.markdown} > **{file:docs/FixedLayout.markdow}**

Fixed-Layout Documents
======================

Since v0.1.4, EPUB Parser supports Fixed-Layout Documents by {EPUB::Publication::FixedLayout} module.
It is set "on" when `rendition` property exists in `prefix` attribute of `package` element in rootfile.

EPUB Fixed-Layout defines some additional properties to see how to render Content Documents. This EPUB Parser library supports it by providing convenience methods to know how to render.

Methods for {EPUB::Publication::Package}
----------------------------------------

### {EPUB::Publication::FixedLayout::PackageMixin#using_fixed_layout #using_fixed_layout}

It is true when `package@prefix` attribute has `rendition` property.

    parser = EPUB::Parser::Publication.new(<<OPF, 'dummy/rootfile.opf')
    <package version="3.0"
             unique-identifier="pub-id"
             xmlns="http://www.idpf.org/2007/opf"
             prefix="rendition: http://www.idpf.org/vocab/rendition/#">
    </package>
    OPF
    package = parser.parse_package
    package.using_fixed_layout # => true

And you can set by your self:

    package.using_fixed_layout = true

References
----------

* [Fixed-Layout Documents][fixed-layout] on IDPF site

[fixed-layout]: http://www.idpf.org/epub/fxl/
