{file:docs/Home.markdown} > **{file:docs/Item}**

Overview
========

When manipulating resources (XHTML, images, audio...) in EPUB, {EPUB::Publication::Package::Manifest::Item} object will be used.
And objects which {EPUB#each_page_on_spine} yields are also instances of this class.

Here's the tutorial of this class.

Getting Items
=============

Getting the {EPUB::Publication::Package::Manifest::Item Item} object you want is due to other classes, mainly {EPUB} module:

    book = EPUB::Parser.parse('book.epub')
    book.resouces                    # => all items including XHTMLs, CSSs, images, audios and so on
    book.cover_image                 # => item representing cover image file
    book.each_page_on_spine do |page|
      page                           # => item in spine(order of "page" the author determined, often XHTML file)
    end
    book.package.manifest.navs       # => navigation items(XHTML files including <nav> element)
    book.package.manifest['item-id'] # => item referenced by the ID "item-id"

For the last two examples, knowledge for EPUB structure is required.

Using Items
===========

Once you've got an {EPUB::Publication::Package::Manifest::Item Item}, it provides informations about the item(file).

    item.id                   # => the ID of the item
    item.media_type           # => media type like application/xhtml+xml
    item.href                 # => Addressable::URI object which represents the IRI of the item
    item.properties           # => array of properties
    item.fallback             # => see the next section for details
    item.fallback_chain       # => ditto.
    item.using_fallback_chain # => ditto.

And {EPUB::Publication::Package::Manifest::Item Item} also provides some methods which helps you handle the item.

For example, for XHTML:

    item.read                # => content of the item
    Nokogiri.HTML(item.read) #=> Nokogiri::HTML::Document object

For image:

    uri = 'data:' + item.media_type + '; base64,' + Base64.encode64(item.read)
    img = %Q!<img src="#{uri}" alt="#{item.id}">!

Fallback Chain
==============

Some items have {EPUB::Publication::Package::Manifest::Item#fallback `fallback`} attribute, which provides the item to be used when reading system(your app) cannot handle with given item for some reason(for example, media type not supported).

Of course, you can get it by calling {EPUB::Publication::Package::Manifest::Item#fallback `fallback`} method:

    item.fallback # => fallback `Item` or nil

Also you can use {EPUB::Publication::Package::Manifest::Item#use_fallback_chain `use_fallback_chain`} not to check if you can accept item or not for every item:

    item.use_fallback_chain :supported => 'image/png' do |png|
      # do something with PNG image
    end

If item's media type is, for instance, 'image/x-eps', the fallback is used.
If the fallback item's media type is 'image/png', `png` variable means the item, if not, "fallback of fallback" will be checked.
Finally you can use the item you want, or {EPUB::Constants::MediaType::UnsupportedError EPUB::MediaType::UnsupportedError} exception will be raised(if no item you can accept found).
Therefore, you should `rescue` clause:

    # :unsupported option can also be used
    # fallback chain will be followed until EPUB's Core Media Types found or UnsupportedError raised
    begin
      item.use_fallback_chain :unsupported => 'application/pdf' do |page|
        # do something with item with core media type
      end
    rescue EPUB::MediaType::UnsupportedError => evar
      # error handling
    end
