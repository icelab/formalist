require "dry/schema"
require "formalist/form"
require "formalist/elements/standard"
require "formalist/rich_text/embedded_forms_container"
require "formalist/rich_text/embedded_form_compiler"

RSpec.describe Formalist::RichText::EmbeddedFormCompiler do
  let(:compiler) { described_class.new(embedded_forms) }

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
    Dry::Schema.Params do
      required(:image_id).filled(:integer)
      required(:caption).filled(:string)
    end
  }

  describe "valid data" do
    let(:input) {
      [
        ["block",["unstyled","b14hd",[["inline",[[],"Before!"]]]]],
        ["block",["atomic","48b4f",[["entity",["formalist","1","IMMUTABLE",{"name" => "image_with_caption","label" => "Image with caption","data" => {"image_id" => 5678,"caption" => "Large panda"}},[["inline",[[],"¶"]]]]]]]],
        ["block",["unstyled","aivqi",[["inline",[[],"After!"]]]]]
      ]
    }

    let(:output) {
      compiler.(input)
    }

    it "builds a form AST with the data incorporated" do
      expect(output[1]).to eq ["block", ["atomic", "48b4f", [["entity", ["formalist", "1", "IMMUTABLE", {"name" => "image_with_caption", "label" => "Image with caption", "data" => {"image_id" => 5678, "caption" => "Large panda"}, "form" => [[:field, [:image_id, :text_field, 5678, [], [:object, []]]], [:field, [:caption, :text_field, "Large panda", [], [:object, []]]]]}, [["inline", [[], "¶"]]]]]]]]
    end

    it "leaves the rest of the data unchanged" do
      expect(output[0]).to eq input[0]
      expect(output[2]).to eq input[2]
      expect(output.length).to eq 3
    end
  end

  describe "invalid data" do
    let(:input) {
      [
        ["block",["unstyled","b14hd",[["inline",[[],"Before!"]]]]],
        ["block",["atomic","48b4f",[["entity",["formalist","1","IMMUTABLE",{"name" => "image_with_caption","label" => "Image with caption","data" => {"image_id" => "","caption" => "Large panda"}},[["inline",[[],"¶"]]]]]]]],
        ["block",["unstyled","aivqi",[["inline",[[],"After!"]]]]]
      ]
    }

    let(:output) {
      compiler.(input)
    }

    it "builds a form AST with the data and validation messages incorporated" do
      expect(output[1]).to eq ["block", ["atomic", "48b4f", [["entity", ["formalist", "1", "IMMUTABLE", {"name" => "image_with_caption", "label" => "Image with caption", "data" => {"image_id" => "", "caption" => "Large panda"}, "form" => [[:field, [:image_id, :text_field, "", ["must be filled"], [:object, []]]], [:field, [:caption, :text_field, "Large panda", [], [:object, []]]]]}, [["inline", [[], "¶"]]]]]]]]
    end

    it "leaves the rest of the data unchanged" do
      expect(output[0]).to eq input[0]
      expect(output[2]).to eq input[2]
      expect(output.length).to eq 3
    end
  end
end
