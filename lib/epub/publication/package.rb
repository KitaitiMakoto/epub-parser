%w[ metadata manifest spine guide ].each { |f| require "epub/publication/package/#{f}" }

module EPUB
  module Publication
    class Package
      attr_accessor :version, :unique_identifier, :prefix, :xml_lang, :dir, :id,
                    :metadata, :manifest, :spine
      alias lang  xml_lang
      alias lang= xml_lang=
    end
  end
end
