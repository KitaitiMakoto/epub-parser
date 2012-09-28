module EPUB
  module Publication
    class Package
      CONTENT_MODELS = [:metadata, :manifest, :spine, :guide, :bindings]

      class << self
        def define_content_model(model_name)
          define_method "#{model_name}=" do |model|
            current_model = __send__(model_name)
            current_model.package = nil if current_model
            model.package = self
            instance_variable_set "@#{model_name}", model
          end
        end
      end

      attr_accessor :book,
                    :version, :prefix, :xml_lang, :dir, :id
      attr_reader *CONTENT_MODELS
      alias lang  xml_lang
      alias lang= xml_lang=

      CONTENT_MODELS.each do |model|
        define_content_model model
      end

      def unique_identifier
        @metadata.unique_identifier
      end
    end
  end
end

EPUB::Publication::Package::CONTENT_MODELS.each do |f|
  require_relative "package/#{f}"
end
