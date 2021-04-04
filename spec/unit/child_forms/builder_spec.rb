require "dry/validation/contract"
require "formalist/form"
require "formalist/elements/standard"
require "formalist/rich_text/embedded_forms_container"
require "formalist/child_forms/builder"

RSpec.describe Formalist::ChildForms::Builder do
  let(:builder) { described_class.new(embedded_forms) }

  let(:embedded_forms) {
    Formalist::RichText::EmbeddedFormsContainer.new.tap do |collection|
      collection.register :image_with_caption, label: "Image with caption", form: form, schema: schema
    end
  }

  let(:form) {
    Class.new(Formalist::Form) do
      define do
        text_field :image_id
        text_field :caption
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

  describe "valid data" do
    let(:input) {
      [
        {:name => "image_with_caption",:label => "Image with caption",:data => {"image_id" => 5678,"caption" => "Large panda"}},
      ]
    }

    let(:output) {
      builder.(input)
    }

    it "builds a list of form elements with input AST containing form data" do
      expect(output.count).to eq 1
      expect(output.first).to be_a_kind_of(Formalist::ChildForms::ChildForm)
      expect(output.first.input).to eq([[:field, [:image_id, :text_field, 5678, [], [:object, []]]], [:field, [:caption, :text_field, "Large panda", [], [:object, []]]]])
    end
  end

  describe "invalid data" do
    let(:input) {
      [
        {:name => "image_with_caption",:label => "Image with caption",:data => {"image_id" => "","caption" => "Large panda"}},
      ]
    }

    let(:output) {
      builder.(input)
    }

    it "builds a list of form elements with input ast containing form data and errors" do
      expect(output.count).to eq 1
      expect(output.first).to be_a_kind_of(Formalist::ChildForms::ChildForm)
      expect(output.first.input).to eq([[:field, [:image_id, :text_field, "", ["must be filled"], [:object, []]]], [:field, [:caption, :text_field, "Large panda", [], [:object, []]]]])
    end
  end

  describe "missing form definition" do
    let(:input) {
      [
        {:name => "deprecated_form",:label => "Old Image with caption", :data => {"image_url" => "/assets/large-panda", "caption" => "Large panda"}},
      ]
    }

    it "raises a missing form definition error" do
      expect { builder.(input).to raise_error(MissingFormDefinitionError) }
    end
s
  end
end
