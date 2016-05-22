module EPUB
  class Parser
    module Metadata
      def parse_metadata(elem, unique_identifier_id, default_namespace)
        metadata = EPUB::Publication::Package::Metadata.new
        id_map = {}

        metadata.identifiers = extract_model(elem, id_map, './dc:identifier', :Identifier, ['id']) {|identifier, e|
          identifier.scheme = extract_attribute(e, 'scheme', 'opf')
          metadata.unique_identifier = identifier if identifier.id == unique_identifier_id
        }
        metadata.titles = extract_model(elem, id_map, './dc:title', :Title)
        metadata.languages = extract_model(elem, id_map, './dc:language', :DCMES, %w[id])
        %w[contributor coverage creator date description format publisher relation source subject type].each do |dcmes|
          metadata.__send__ "#{dcmes}s=", extract_model(elem, id_map, "./dc:#{dcmes}")
        end
        metadata.rights = extract_model(elem, id_map, './dc:rights')
        metadata.metas = extract_refinee(elem, id_map, "./#{default_namespace}:meta", :Meta, %w[property id scheme])
        metadata.links = extract_refinee(elem, id_map, "./#{default_namespace}:link", :Link, %w[id media-type]) {|link, e|
          link.href = extract_attribute(e, 'href')
          link.rel = Set.new(extract_attribute(e, 'rel').split(nil))
        }

        id_map.values.each do |hsh|
          next unless hsh[:refiners]
          next unless hsh[:metadata]
          hsh[:refiners].each {|meta| meta.refines = hsh[:metadata]}
        end

        metadata
      end

      def extract_model(elem, id_map, xpath, klass=:DCMES, attributes=%w[id lang dir])
        models = elem.xpath(xpath, EPUB::NAMESPACES).collect do |e|
          model = EPUB::Publication::Package::Metadata.const_get(klass).new
          attributes.each do |attr|
            model.__send__ "#{attr.gsub(/-/, '_')}=", extract_attribute(e, attr)
          end
          model.content = e.content unless klass == :Link

          yield model, e if block_given?

          model
        end

        models.each do |model|
          id_map[model.id] = {metadata: model} if model.respond_to?(:id) && model.id
        end

        models
      end

      def extract_refinee(elem, id_map, xpath, klass, attributes)
        extract_model(elem, id_map, xpath, klass, attributes) {|model, e|
          yield model, e if block_given?
          refines = extract_attribute(e, 'refines')
          if refines && refines[0] == '#'
            id = refines[1..-1]
            id_map[id] ||= {}
            id_map[id][:refiners] ||= []
            id_map[id][:refiners] << model
          end
        }
      end
    end
  end
end
