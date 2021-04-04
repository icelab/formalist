require "dry/validation/contract"

RSpec.describe Formalist::Form do
  let(:contract) {
    Class.new(Dry::Validation::Contract) do
      schema do
        required(:title).filled(:string)
        required(:rating).filled(:integer)

        required(:reviews).array(:hash) do
          required(:summary).filled(:string)
          required(:rating).filled(:integer, gteq?: 1, lteq?: 10)
        end

        required(:meta).hash do
          required(:pages).filled(:integer, gteq?: 1)
        end
      end
    end.new
  }

  subject(:form_class) {
    Class.new(Formalist::Form) do
      define do
        compound_field do
          field :title, validate: {filled: true}
          field :rating, validate: {filled: true}
        end

        many :reviews do
          field :summary, validate: {filled: true}
          field :rating, validate: {filled: true}
        end

        attr :meta do
          field :pages, validate: {filled: true}
        end
      end
    end
  }

  let(:input) {
    {
      title: "Aurora",
      rating: "10",
      reviews: [
        {
          summary: "",
          rating: 10
        },
        {
          summary: "Great!",
          rating: 0
        }
      ],
      meta: {
        pages: 0
      }
    }
  }

  it "outputs an AST" do
    form = form_class.new.fill(input: input, errors: contract.(input).errors)

    expect(form.to_ast).to eq [
      [:compound_field, [
        :compound_field,
        [:object, []],
        [
          [:field, [:title, :field, "Aurora", [], [:object, []]]],
          [:field, [:rating, :field, "10", ["must be an integer"], [:object, []]]]
        ]
      ]],
      [:many, [
        :reviews,
        :many,
        [],
        [:object, [
          [:allow_create, [:value, [true]]],
          [:allow_update, [:value, [true]]],
          [:allow_destroy, [:value, [true]]],
          [:allow_reorder, [:value, [true]]]
        ]],
        [
          [:field, [:summary, :field, nil, [], [:object, []]]],
          [:field, [:rating, :field, nil, [], [:object, []]]]
        ],
        [
          [
            [:field, [:summary, :field, "", ["must be filled"], [:object, []]]],
            [:field, [:rating, :field, 10, [], [:object, []]]]
          ],
          [
            [:field, [:summary, :field, "Great!", [], [:object, []]]],
            [:field, [:rating, :field, 0, ["must be greater than or equal to 1"], [:object, []]]]
          ]
        ]
      ]],
      [:attr, [
        :meta,
        :attr,
        [],
        [:object, []],
        [
          [:field, [:pages, :field, 0, ["must be greater than or equal to 1"], [:object, []]]]
        ]
      ]]
    ]
  end
end
