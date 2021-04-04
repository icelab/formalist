require "json"
require_relative "builder"

module Formalist
  module ChildForms
    class ParamsProcessor
      attr_reader :embedded_forms

      def initialize(embedded_form_collection)
        @embedded_forms = embedded_form_collection
      end

      def call(input)
        return input if input.nil?
        input.inject([]) { |output, node| output.push(process(node)) }
      end
      alias_method :[], :call

      private

      def process(node)
        name, data = node.values_at(:name, :data)

        validation = embedded_forms[name].schema.(data)
        node.merge(data: validation.to_h)
      end

    end
  end
end
