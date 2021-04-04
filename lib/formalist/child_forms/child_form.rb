require "formalist/element"

module Formalist
  module ChildForms
    class ChildForm < Element
      DEFAULT_INPUT_PROCESSOR = -> input { input }.freeze

      attribute :label
      attribute :form
      attribute :schema
      attribute :input_processor, default: DEFAULT_INPUT_PROCESSOR
      attribute :preview_image_url

      def fill(input: {}, errors: {})
        super(input: form_input_ast(input), errors: errors.to_a)
      end

      def attributes
        super.merge(form: form_attribute_ast)
      end

      def form_attribute_ast
        @attributes[:form].to_ast
      end

      def form_input_ast(data)
        # Run the raw data through the validation schema
        validation = @attributes[:schema].(data)

        # And then through the embedded form's input processor (which may add
        # extra system-generated information necessary for the form to render
        # fully)
        input = @attributes[:input_processor].(validation.to_h)

        @attributes[:form].fill(input: input, errors: validation.errors.to_h).to_ast
      end

      def to_ast
        [:child_form, [
          name,
          type,
          input,
          Element::Attributes.new(attributes).to_ast,
        ]]
      end
    end
  end
end
