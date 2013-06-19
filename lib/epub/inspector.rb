module EPUB
  module Inspector
    INSTANCE_VARIABLES_OPTION = {:exclude => []}

    def inspect_simply
      "#<%{class}:%{object_id}>" % {
        :class => self.class,
        :object_id => inspect_object_id
      }
    end

    def inspect_object_id
      (__id__ << 1).to_s(16)
    end

    def inspect_instance_variables(options={})
      options = INSTANCE_VARIABLES_OPTION.merge(options)
      exclude = options[:exclude]

      (instance_variables - exclude).map {|name|
        value = instance_variable_get(name)
        "#{name}=#{value.inspect}"
      }.join(' ')
    end

    module PublicationModel
      class << self
        def included(mod)
          mod.__send__ :include, Inspector
        end
      end

      def inspect
          "#<%{class}:%{object_id} @package=%{package} %{attributes}>" % {
            :class      => self.class,
            :package    => package.inspect_simply,
            :object_id  => inspect_object_id,
            :attributes => inspect_instance_variables(exclude: [:@package])
          }
      end
    end
  end
end
