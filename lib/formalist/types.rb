# coding: utf-8
require "dry/types"

# TODO: Find a way to avoid registering this globally
Dry::Logic::Predicates.predicate :respond_to? do |method_name, value|
  value.respond_to?(method_name)
end

module Formalist
  module Types
    include Dry::Types.module

    ElementName = Types::Strict::Symbol.constrained(min_size: 1).optional
    OptionsList = Types::Array.of(Formalist::Types::Array.of(Formalist::Types::Strict::String).constrained(size: 2))

    # The SelectionField and MultiSelectionField require a _somewhat_ specific
    # data structure:
    #
    #     {id: 123, label: 'foo'}
    #
    # It’s expected that `id` is the relational representation of the object.
    # And label could/should be optional if the form defines a custom
    # `render_as` attribute
    SelectionsList = Formalist::Types::Strict::Array.of(Formalist::Types::Strict::Hash)

    Validation = Types::Strict::Hash

    Dependency = Dry::Types['any']
    Function = Dependency.constrained(respond_to: :call)
  end
end
