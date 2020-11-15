# frozen_string_literal: true

require 'sums_up/core'
require 'sums_up/version'

# UI-level functions for the gem.
module SumsUp
  Error = Class.new(StandardError)

  MatchError = Class.new(Error)
  UnmatchedVariantError = Class.new(MatchError)
  MatchAfterWildcardError = Class.new(MatchError)
  DuplicateMatchError = Class.new(MatchError)
end
