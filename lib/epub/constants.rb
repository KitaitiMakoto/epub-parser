module EPUB
  module Constants
    NAMESPACES = {
      'dc'        => 'http://purl.org/dc/elements/1.1/',
      'container' => 'urn:oasis:names:tc:opendocument:xmlns:container',
      'opf'       => 'http://www.idpf.org/2007/opf',
      'xhtml'     => 'http://www.w3.org/1999/xhtml',
      'epub'      => 'http://www.idpf.org/2007/ops',
      'm'         => 'http://www.w3.org/1998/Math/MathML',
      'svg'       => 'http://www.w3.org/2000/svg'
    }
    module Type
      TOC       = 'toc'
      PAGE_LIST = 'page_list'
      LANDMARKS = 'landmarks'
    end
  end

  include Constants
end
