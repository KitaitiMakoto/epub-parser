require 'pathname'
require 'tmpdir'
require 'epub/parser'
require 'epub/ocf/physical_container/unpacked_uri'

EPUB_URI = URI.parse(ARGV.shift)
DOWNLOAD_DIR = Pathname.new(ARGV.shift || Dir.mktmpdir('epub-parser'))
$stderr.puts <<EOI
Started downloading EPUB contents...
  from: #{EPUB_URI}
  to:   #{DOWNLOAD_DIR}
EOI

# Make it possible to use URI as EPUB file path
EPUB::OCF::PhysicalContainer.adapter = :UnpackedURI

def main
  make_mimetype

  container_xml = 'META-INF/container.xml'
  download container_xml

  epub = EPUB::Parser.parse(EPUB_URI, container_adapter: :UnpackedURI)
  download epub.rootfile_path

  epub.resources.each do |resource|
    download resource.entry_name
  end
  puts DOWNLOAD_DIR
end

def make_mimetype
  $stderr.puts "Making mimetype file..."
  DOWNLOAD_DIR.join('mimetype').write 'application/epub+zip'
end

def download(path)
  path = path.to_s
  src = EPUB_URI + path
  dest = DOWNLOAD_DIR + path
  $stderr.puts "Downloading #{path} ..."
  dest.dirname.mkpath
  dest.write src.read
end

main
