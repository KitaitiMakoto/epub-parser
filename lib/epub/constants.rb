module EPUB
  NAMESPACES = {
    'xml'   => 'http://www.w3.org/XML/1998/namespace',
    'dc'    => 'http://purl.org/dc/elements/1.1/',
    'ocf'   => 'urn:oasis:names:tc:opendocument:xmlns:container',
    'opf'   => 'http://www.idpf.org/2007/opf',
    'xhtml' => 'http://www.w3.org/1999/xhtml',
    'epub'  => 'http://www.idpf.org/2007/ops',
    'm'     => 'http://www.w3.org/1998/Math/MathML',
    'svg'   => 'http://www.w3.org/2000/svg',
    'smil'  => 'http://www.w3.org/ns/SMIL',
    'metadata' => 'http://www.idpf.org/2013/metadata'
  }

  module MediaType
    class UnsupportedMediaType < StandardError; end

    EPUB = 'application/epub+zip'
    ROOTFILE = 'application/oebps-package+xml'
    IMAGE = %w[
      image/gif
      image/jpeg
      image/png
      image/svg+xml
    ]
    APPLICATION = %w[
      application/xhtml+xml
      application/x-dtbncx+xml
      application/vnd.ms-opentype
      application/font-woff
      application/smil+xml
      application/pls+xml
    ]
    AUDIO = %w[
      audio/mpeg
      audio/mp4
    ]
    TEXT = %w[
      text/css
      text/javascript
    ]
    CORE = IMAGE + APPLICATION + AUDIO + TEXT
  end
end
