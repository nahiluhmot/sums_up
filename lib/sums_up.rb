# frozen_string_literal: true

require 'forwardable'

require 'sums_up/core'
require 'sums_up/version'

# UI-level functions for the gem.
module SumsUp
  Error = Class.new(StandardError)

  MatchError = Class.new(Error)
  UnmatchedVariantError = Class.new(MatchError)
  MatchAfterWildcardError = Class.new(MatchError)
  DuplicateMatchError = Class.new(MatchError)
  UnknownVariantError = Class.new(MatchError)

  ParserError = Class.new(Error)
  VariantNameError = Class.new(ParserError)
  VariantArgsError = Class.new(ParserError)
  DuplicateNameError = Class.new(ParserError)

  class << self
    extend Forwardable

    def_delegators(Core, :define)
  end
end

require 'sums_up/maybe'
require 'sums_up/result'
