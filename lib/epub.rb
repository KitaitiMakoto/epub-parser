require 'epub/ocf'
require 'epub/publication'
require 'epub/content_document'

module EPUB
  modules = [ :ocf, :package, :content_document ]
  attr_reader *modules
  attr_accessor :epub_file
  modules.each do |mod|
    define_method "#{mod}=" do |obj|
      instance_variable_set "@#{mod}", obj
      obj.book = self
    end
  end

  def parse(file, options = {})
    @epub_file = file
    options = options.merge({:book => self})
    Parser.parse(file, options)
  end

  Publication::Package::CONTENT_MODELS.each do |model|
    define_method model do
      package.__send__(model)
    end
  end

  %w[ title main_title subtitle short_title collection_title edition_title extended_title ].each do |met|
    define_method met do
      metadata.__send__(met)
    end
  end

  def each_page_on_spine(&blk)
    enum = package.spine.items
    if block_given?
      enum.each &blk
    else
      enum
    end
  end

  def each_page_on_toc(&blk)
    raise NotImplementedError
  end

  def each_content(&blk)
    enum = manifest.items
    if block_given?
      enum.each &blk
    else
      enum.to_enum
    end
  end

  def other_navigation
    raise NotImplementedError
  end

  def resources
    manifest.items
  end

  # Syntax sugar
  def rootfile_path
    ocf.container.rootfile.full_path
  end

  # Syntax sugar
  def cover_image
    manifest.cover_image
  end
end
