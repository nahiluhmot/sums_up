# frozen_string_literal: true

module SumsUp
  # To paraphrase Haskell's Data.Maybe docs[0]:
  #
  # Maybe represents an optional value. A Maybe value contains either a value
  # (Maybe.just(1)), or is empty (Maybe.nothing).
  #
  # [0] https://hackage.haskell.org/package/base-4.14.0.0/docs/Data-Maybe.html
  Maybe = SumsUp.define(:nothing, just: :value) do
    # Build a new Maybe from a value which may or may not be nil.
    def self.of(value)
      if value.nil?
        nothing
      else
        just(value)
      end
    end

    # Map a function across the Maybe. If present, the value is yielded and that
    # result is wrapped in a new Maybe.just. Returns Maybe.nothing otherwise.
    def map
      match do |m|
        m.just { |value| Maybe.just(yield(value)) }
        m.nothing Maybe.nothing
      end
    end

    # On nothing, return the provided default value (or yield). On just, return
    # the value.
    def or_else(default = nil)
      match do |m|
        m.just { |value| value }
        m.nothing do
          block_given? ? yield : default
        end
      end
    end
  end
end
