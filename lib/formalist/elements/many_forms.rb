require "formalist/element"
require "formalist/child_forms/builder"

module Formalist
  class Elements
    class ManyForms < Element
      attribute :action_label
      attribute :sortable
      attribute :moveable
      attribute :label
      attribute :max_height
      attribute :placeholder
      attribute :embeddable_forms
      attribute :validation
      attribute :allow_create, default: true
      attribute :allow_update, default: true
      attribute :allow_destroy, default: true
      attribute :allow_reorder, default: true

      # FIXME: it would be tidier to have a reader method for each attribute
      def attributes
        super.merge(embeddable_forms: embeddable_forms_ast)
      end

       # @api private
       def fill(input: {}, errors: {})
        input = input[name] || []
        errors = errors[name].to_a

        children = child_form_builder.(input)

        super(
          input: input,
          errors: errors,
          children: children,
        )
      end

      # Replace the form objects with their AST
      def embeddable_forms_ast
        @attributes[:embeddable_forms].to_h.map { |key, attrs|
          template_attrs = attrs.slice(:label, :preview_image_url)

          [
            key,
            attrs.merge(
              form: attrs[:form].to_ast,
              attributes_template: Element::Attributes.new(template_attrs).to_ast
            )
          ]
        }.to_h
      end

      def child_form_builder
        ChildForms::Builder.new(@attributes[:embeddable_forms])
      end

      # Converts a collection of "many" repeating elements into an abstract
      # syntax tree.
      #
      # It takes the following format:
      #
      # ```
      # [:many_forms, [params]]
      # ```
      #
      # With the following parameters:
      #
      # 1. Collection name
      # 2. Custom form element type (or `:many_forms` otherwise)
      # 3. Collection-level error messages
      # 4. Form element attributes
      # 6. Child elements, one for each of the entries in the input data (or
      #    none, if there is no or empty input data)
      #
      # @see Formalist::Element::Attributes#to_ast "Form element attributes" structure
      #
      # @example "components" collection
      #   many_forms.to_ast
      #   # => [:many_forms, [
      #     :components,
      #     :many_forms,
      #     ["components size cannot be less than 3"],
      #     [:object, [
      #       [:allow_create, [:value, [true]]],
      #       [:allow_update, [:value, [true]]],
      #       [:allow_destroy, [:value, [true]]],
      #       [:allow_reorder, [:value, [true]]]
      #     ]],
      #     [
      #       [
      #        [:child_form,
      #         [:image_with_captions,
      #          :child_form,
      #            [[:field, [:image_id, :text_field, "", ["must be filled"], [:object, []]]], [:field, [:caption, :text_field, "Large panda", [], [:object, []]]]],
      #           [:object, []]
      #     ]
      #   ]]
      #
      # @return [Array] the collection as an abstract syntax tree.
      def to_ast
        local_errors = errors.is_a?(Array) ? errors : []

        [:many_forms, [
          name,
          type,
          local_errors,
          Element::Attributes.new(attributes).to_ast,
          children.map(&:to_ast)
        ]]
      end

    end
  end
end
