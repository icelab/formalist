require "spec_helper"
require "formalist/elements/many_forms"
require "dry/validation/contract"
require "formalist/rich_text/embedded_forms_container"


RSpec.describe Formalist::Elements::ManyForms do
  subject(:many_forms) {
    Formalist::Elements::ManyForms.new(
      name: :components,
      attributes: attributes,
    ).fill(
      input: input,
      errors: errors,
    )
  }

  let(:child_form) {
    Class.new(Formalist::Form) do
      define do
        field :image_id
        field :caption
      end
    end.new
  }

  let(:child_schema) {
    Class.new(Dry::Validation::Contract) do
      params do
        required(:image_id).filled(:integer)
        required(:caption).filled(:string)
      end
    end.new
  }

  let(:embedded_forms) {
    Formalist::RichText::EmbeddedFormsContainer.new.tap do |collection|
      collection.register :image_with_caption, label: "Image with caption", form: child_form, schema: child_schema
    end
  }

  let(:attributes) { {label: "Components", embeddable_forms: embedded_forms} }
  let(:errors) { {} }

  describe "input" do
    context "is valid form data" do
      let(:input) {
        {
          title: "Aurora",
          components: [
            {
              name: :image_with_caption,
              label: "Image with caption",
              data: {
                image_id: 1234,
                caption: "Cute cat"
              }
            }
          ],
        }
      }

      it "converts the input data to valid form AST" do
        expect(many_forms.children.count).to eql 1

        expect(many_forms.children.first.input).to eql [
          [:field, [:image_id, :field, 1234, [], [:object, []]]],
          [:field, [:caption, :field, "Cute cat", [], [:object, []]]]
        ]
      end
    end

    context "is invalid form data" do
      let(:input) {
        {
          title: "Aurora",
          components: [
            {
              name: :image_with_caption,
              label: "Image with caption",
              data: {
                image_id: nil,
                caption: "Cute cat"
              }
            }
          ],
        }
      }

      it "converts the input data to valid form AST with validation errors" do
        expect(many_forms.children.first.input).to eql [
          [:field, [:image_id, :field, nil, ["must be filled"], [:object, []]]],
          [:field, [:caption, :field, "Cute cat", [], [:object, []]]]
        ]
      end
    end
  end
end
