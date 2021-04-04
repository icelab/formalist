require "dry/validation/contract"
require "formalist/child_forms/params_processor"

RSpec.describe Formalist::ChildForms::ParamsProcessor do
  subject(:processor) { described_class.new(embeddable_forms) }

  let(:embedded_form) { double(:embedded_form) }

  let(:contract) {
    Class.new(Dry::Validation::Contract) do
      params do
        required(:title).filled(:string)
        required(:visible).filled(:bool)
      end
    end.new
  }

  let(:embeddable_forms) {
    {call_to_action: embedded_form}
  }

  before do
    allow(embedded_form).to receive(:schema).and_return(contract)
  end

  describe "#call" do
    subject(:result) { processor.(input) }

    context "valid forms list" do
      let(:input) {
        [
          {
            name: :call_to_action,
            label: "Call to action",
            data: {
              title: "Find out more!",
              visible: "true"
            }
          },
          {
            name: :call_to_action,
            label: "Call to action",
            data: {
              title: "Another call!",
              visible: "false"
            }
          }
        ]
      }

      it { is_expected.to eql([
        {
          name: :call_to_action,
          label: "Call to action",
          data: {
            title: "Find out more!",
            visible: true
          }
        },
        {
          name: :call_to_action,
          label: "Call to action",
          data: {
            title: "Another call!",
            visible: false
          }
        }
      ])

      }
    end

    context "at least one invalid form input" do
      let(:input) {
        [
          {
            name: :call_to_action,
            label: "Call to action",
            data: {
              title: "Find out more!",
              visible: true
            }
          },
          {
            name: :call_to_action,
            label: "Call to action",
            data: {
              title: ""
            }
          },
        ]
      }

      it { is_expected.to eq(
        [
          {
            name: :call_to_action,
            label: "Call to action",
            data: {
              title: "Find out more!",
              visible: true
            }
          },
          {
            name: :call_to_action,
            label: "Call to action",
            data: {
              title: ""
            }
          },
        ]
      )}
    end

    context "empty input" do
      let(:input) { [] }

      it { is_expected.to eq [] }
    end
  end
end
