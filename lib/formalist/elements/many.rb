require "formalist/element"

module Formalist
  class Elements
    class Many < Element
      attribute :action_label
      attribute :sortable
      attribute :moveable
      attribute :label
      attribute :max_height
      attribute :placeholder
      attribute :validation
      attribute :allow_create, default: true
      attribute :allow_update, default: true
      attribute :allow_destroy, default: true
      attribute :allow_reorder, default: true

      # @api private
      attr_reader :child_template

      # @api private
      def self.build(children: [], **args)
        child_template = children.dup
        super(child_template: child_template, **args)
      end

      # @api private
      def initialize(child_template:, **args)
        @child_template = child_template
        super(**args)
      end

      # @api private
      def fill(input: {}, errors: {})
        input = input.fetch(name) { [] }
        errors = errors[name] || {}

        # Errors look like this when they are on the array itself: ["size cannot be greater than 2"]
        # Errors look like this when they are on children: {0=>{:summary=>["must be filled"]}

        children = input.each_with_index.map { |child_input, index|
          child_errors = errors.is_a?(Hash) ? errors.fetch(index) { {} } : {}

          child_template.map { |child| child.fill(input: child_input, errors: child_errors) }
        }

        super(
          input: input,
          errors: errors,
          children: children,
          child_template: child_template,
        )
      end

      # Converts a collection of "many" repeating elements into an abstract
      # syntax tree.
      #
      # It takes the following format:
      #
      # ```
      # [:many, [params]]
      # ```
      #
      # With the following parameters:
      #
      # 1. Collection name
      # 2. Custom form element type (or `:many` otherwise)
      # 3. Collection-level error messages
      # 4. Form element attributes
      # 5. Child element "template" (i.e. the form elements comprising a
      #    single entry in the collection of "many" elements, without any user
      #    data associated)
      # 6. Child elements, one for each of the entries in the input data (or
      #    none, if there is no or empty input data)
      #
      # @see Formalist::Element::Attributes#to_ast "Form element attributes" structure
      #
      # @example "locations" collection
      #   many.to_ast
      #   # => [:many, [
      #     :locations,
      #     :many,
      #     ["locations size cannot be less than 3"],
      #     [:object, [
      #       [:allow_create, [:value, [true]]],
      #       [:allow_update, [:value, [true]]],
      #       [:allow_destroy, [:value, [true]]],
      #       [:allow_reorder, [:value, [true]]]
      #     ]],
      #     [
      #       [:field, [:name, :field, nil, [], [], [:object, []]]],
      #       [:field, [:address, :field, nil, [], [], [:object, []]]]
      #     ],
      #     [
      #       [
      #         [:field, [:name, :field, "Icelab Canberra", [], [], [:object, []]]],
      #         [:field, [:address, :field, "Canberra, ACT, Australia", [], [], [:object, []]]]
      #       ],
      #       [
      #         [:field, [:name, :field, "Icelab Melbourne", [], [], [:object, []]]],
      #         [:field, [:address, :field, "Melbourne, VIC, Australia", [], [], [:object, []]]]
      #       ]
      #     ]
      #   ]]
      #
      # @return [Array] the collection as an abstract syntax tree.
      def to_ast
        local_errors = errors.is_a?(Array) ? errors : []

        [:many, [
          name,
          type,
          local_errors,
          Element::Attributes.new(attributes).to_ast,
          child_template.map(&:to_ast),
          children.map { |el_list| el_list.map(&:to_ast) },
        ]]
      end
    end
  end
end
