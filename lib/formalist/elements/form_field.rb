require "formalist/child_forms/child_form"

module Formalist
  class Elements
    class FormField < ChildForms::ChildForm
      attribute :hint

      def fill(input: {}, errors: {})
        input = input[name]
        errors = errors[name].to_a

        super(input: input, errors: errors)
      end

      def to_ast
        [:form_field, [
          name,
          type,
          input,
          Element::Attributes.new(attributes).to_ast,
        ]]
      end
    end
  end
end
