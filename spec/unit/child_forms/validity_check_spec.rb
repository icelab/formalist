require "dry/validation/contract"
require "formalist/child_forms/validity_check"

RSpec.describe Formalist::ChildForms::ValidityCheck do
  subject(:check) { described_class.new(embeddable_forms) }

  let(:embedded_form) { double(:embedded_form) }

  let(:contract) {
    Class.new(Dry::Validation::Contract) do
      schema do
        required(:title).filled(:string)
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
    subject(:result) { check.(input) }

    context "valid forms list" do
      let(:input) {
        [
          {
            name: :call_to_action,
            label: "Call to action",
            data: {
              title: "Find out more!"
            }
          },
          {
            name: :call_to_action,
            label: "Call to action",
            data: {
              title: "Another call!"
            }
          }
        ]
      }

      it { is_expected.to be true }
    end

    context "at least one invalid form input" do
      let(:input) {
        [
          {
            name: :call_to_action,
            label: "Call to action",
            data: {
              title: "Find out more!"
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

      it { is_expected.to be false }
    end

    context "empty input" do
      let(:input) { [] }

      it { is_expected.to be true }
    end
  end
end
