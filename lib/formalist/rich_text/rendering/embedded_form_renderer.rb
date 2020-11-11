module Formalist
  module RichText
    module Rendering
      class EmbeddedFormRenderer
        attr_reader :container
        attr_reader :namespace
        attr_reader :paths
        attr_reader :options

        def initialize(container = {}, namespace: nil, paths: [], **options)
          @container = container
          @namespace = namespace
          @paths = paths
          @options = options
        end

        def call(form_data)
          type, data = form_data.values_at(:name, :data)

          key = resolve_key(type)

          if key
            container[key].(data, options)
          else
            ""
          end
        end

        private

        def resolve_key(type)
          paths.each do |path|
            path_key = path.tr("/", ".")
            key = [namespace, path_key, type].compact.join(".")
            return key if container.key?(key)
          end

          key = [namespace, type].compact.join(".")
          return key if container.key?(key)
        end
      end
    end
  end
end
