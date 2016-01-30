require "formalist/validation/collection_rules_compiler"
require "formalist/validation/value_rules_compiler"
require "formalist/validation/predicate_list_compiler"

module Formalist
  class Form
    class Result
      class Attr
        attr_reader :definition, :input, :value_rules, :value_predicates, :collection_rules, :errors
        attr_reader :children

        def initialize(definition, input, rules, errors)
          value_rules_compiler = Validation::ValueRulesCompiler.new(definition.name)
          value_predicates_compiler = Validation::PredicateListCompiler.new
          collection_rules_compiler = Validation::CollectionRulesCompiler.new(definition.name)

          @definition = definition
          @input = input.fetch(definition.name, {})
          @value_rules = value_rules_compiler.(rules)
          @value_predicates = value_predicates_compiler.(@value_rules)
          @collection_rules = collection_rules_compiler.(rules)
          @errors = errors.fetch(definition.name, [])[0] || []
          @children = build_children
        end

        # Converts the attribute into an array format for including in a
        # form's abstract syntax tree.
        #
        # The array takes the following format:
        #
        # ```
        # [:attr, [params]]
        # ```
        #
        # With the following parameters:
        #
        # 1. Attribute name
        # 1. Validation rules (if any)
        # 1. Validation error messages (if any)
        # 1. Child form elements
        #
        # @example "metadata" attr
        #   attr.to_ast # =>
        #   # [:attr, [
        #   #   :metadata,
        #   #   [
        #   #     [:predicate, [:hash?, []]],
        #   #   ],
        #   #   ["metadata is missing"],
        #   #   [
        #   #     ...child elements...
        #   #   ]
        #   # ]]
        #
        # @return [Array] the attribute as an array.
        def to_ast
          # Errors, if the attr hash is present and its members have errors:
          # {:meta=>[[{:pages=>[["pages is missing"], nil]}], {}]}

          # Errors, if the attr hash hasn't been provided
          # {:meta=>[["meta is missing"], nil]}

          local_errors = errors[0].is_a?(Hash) ? [] : errors

          [:attr, [
            definition.name,
            value_predicates,
            local_errors,
            children.map(&:to_ast),
          ]]
        end

        private

        def build_children
          child_errors = errors[0].is_a?(Hash) ? errors[0] : {}
          definition.children.map { |el| el.(input, collection_rules, child_errors) }
        end
      end
    end
  end
end
