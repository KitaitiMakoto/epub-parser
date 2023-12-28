module EPUB
  class Parser
    module Metadata
      using XMLDocument::Refinements

      def parse_metadata(elem, unique_identifier_id, default_namespace)
        metadata = EPUB::Publication::Package::Metadata.new
        id_map = {}

        default_namespace_uri = EPUB::NAMESPACES[default_namespace]
        elem.each_element do |child|
          elem_name = child.name

          model =
            case child.namespace_uri
            when EPUB::NAMESPACES['dc']
              case elem_name
              when 'identifier'
                identifier = build_model(child, :Identifier, ['id'])
                metadata.identifiers << identifier
                identifier.scheme = child.attribute_with_prefix('scheme', 'opf')
                identifier
              when 'title'
                title = build_model(child, :Title)
                metadata.titles << title
                title
              when 'language'
                language = build_model(child, :DCMES, ['id'])
                metadata.languages << language
                language
              when 'contributor', 'coverage', 'creator', 'date', 'description', 'format', 'publisher', 'relation', 'source', 'subject', 'rights', 'type'
                attr = elem_name == 'rights' ? elem_name : elem_name + 's'
                dcmes = build_model(child)
                metadata.__send__(attr) << dcmes
                dcmes
              else
                build_unsupported_model(child)
              end
            when default_namespace_uri
              case elem_name
              when 'meta'
                meta = build_model(child, :Meta, %w[property id scheme content name])
                metadata.metas << meta
                meta
              when 'link'
                link = build_model(child, :Link, %w[id media-type])
                metadata.links << link
                link.href = child.attribute_with_prefix('href')
                link.rel = Set.new(child.attribute_with_prefix('rel').split(/\s+/))
                link
              else
                build_unsupported_model(child)
              end
            else
              build_unsupported_model(child)
            end

          metadata.children << model

          if model.kind_of?(EPUB::Metadata::Identifier) &&
             model.id == unique_identifier_id
            metadata.unique_identifier = model
          end

          if model.respond_to?(:id) && model.id
            id_map[model.id] = {refinee: model}
          end

          refines = child.attribute_with_prefix('refines')
          if refines && refines.start_with?('#')
            id = refines[1..-1]
            id_map[id] ||= {}
            id_map[id][:refiners] ||= []
            id_map[id][:refiners] << model
          end
        end

        id_map.values.each do |hsh|
          next unless hsh[:refiners]
          next unless hsh[:refinee]
          hsh[:refiners].each {|meta| meta.refines = hsh[:refinee]}
        end

        metadata
      end

      def build_model(elem, klass=:DCMES, attributes=%w[id lang dir])
        model = EPUB::Metadata.const_get(klass).new
        attributes.each do |attr|
          writer_name = (attr == "content") ? "meta_content=" : "#{attr.gsub('-', '_')}="
          namespace = (attr == "lang") ? "xml" : nil
          model.__send__ writer_name, elem.attribute_with_prefix(attr, namespace)
        end
        model.content = elem.content unless klass == :Link
        model.content.strip! if klass == :Identifier
        model
      end

      def build_unsupported_model(elem)
        EPUB::Metadata::UnsupportedModel.new(elem)
      end
    end
  end
end
