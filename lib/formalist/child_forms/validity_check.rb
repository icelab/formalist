require "json"
require_relative "builder"

module Formalist
  module ChildForms
    class ValidityCheck
      attr_reader :embedded_forms

      def initialize(embedded_form_collection)
        @embedded_forms = embedded_form_collection
      end

      def call(input)
        return input if input.nil?
        input.map { |node| valid?(node) }.all?
      end
      alias_method :[], :call

      private

      def valid?(node)
        name, data = node.values_at(:name, :data)

        validation = embedded_forms[name].schema
        validation.(data).success?
      end

    end
  end
end
