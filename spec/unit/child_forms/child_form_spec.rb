require "spec_helper"
require "formalist/child_forms/child_form"
require "dry/validation/contract"

RSpec.describe Formalist::ChildForms::ChildForm do
  subject(:child_form) {
    Formalist::ChildForms::ChildForm.new(
      name: :cta,
      attributes: attributes,
    ).fill(
      input: input,
      errors: errors,
    )
  }

  let(:form) {
    Class.new(Formalist::Form) do
      define do
        field :image_id
        field :caption
      end
    end.new
  }

  let(:schema) {
    Class.new(Dry::Validation::Contract) do
      params do
        required(:image_id).filled(:integer)
        required(:caption).filled(:string)
      end
    end.new
  }

  let(:attributes) { {label: "Call to action", form: form, schema: schema} }
  let(:errors) { {} }

  describe "input" do
    context "is valid form data" do
      let(:input) { {image_id: 12, caption: "A cute panda"} }

      it "converts the input data to valid form AST" do
        expect(child_form.input).to eql [
          [:field, [:image_id, :field, 12, [], [:object, []]]],
          [:field, [:caption, :field, "A cute panda", [], [:object, []]]]
        ]
      end
    end

    context "is invalid form data" do
      let(:input) { {image_id: nil, caption: "A cute panda"} }

      it "converts the input data to valid form AST with validation errors" do
        expect(child_form.input).to eql [
          [:field, [:image_id, :field, nil, ["must be filled"], [:object, []]]],
          [:field, [:caption, :field, "A cute panda", [], [:object, []]]]
        ]
      end
    end
  end
end
