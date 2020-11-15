# frozen_string_literal: true

module SumsUp
  module Core
    # Matching DSL for sum type variants. Methods in this class are prefixed
    # with an _ so as not to conflict with the names of user-defined variant
    # names. Use .build_matcher_class to generate a new subclass for a variant
    # given the other variant names.
    class Matcher
      def self.build_matcher_class(variant, other_variants)
        Class.new(self).tap do |matcher_class|
          matcher_class.const_set(:VARIANT, variant)
          matcher_class.const_set(:ALL_VARIANTS, [variant, *other_variants])
          matcher_class.const_set(
            :IncorrectMatcher,
            incorrect_matcher_module(other_variants)
          )

          matcher_class.include(matcher_class.const_get(:IncorrectMatcher))

          matcher_class.alias_method(variant, :_correct_variant_matcher)
        end
      end

      def self.incorrect_matcher_module(variants)
        variants.each_with_object(Module.new) do |variant, mod|
          mod.define_method(variant) do |_value = nil|
            _ensure_wildcard_not_matched!(variant)
            _ensure_no_duplicate_match!(variant)

            @matched_variants << variant

            self
          end
        end
      end

      def initialize(variant_instance)
        @variant_instance = variant_instance

        @matched = false
        @matched_variants = []
        @wildcard_matched = false
        @result = nil
      end

      def _(value = nil)
        _ensure_wildcard_not_matched!(:_)

        @wildcard_matched = true

        return self if @matched

        @result = block_given? ? yield(@variant_instance) : value

        self
      end

      def _fetch_result
        variants = self.class::ALL_VARIANTS

        return @result if @wildcard_matched
        return @result if @matched_variants.length == variants.length

        unmatched_variants = (variants - @matched_variants).join(', ')

        raise(
          UnmatchedVariantError,
          "Did not match the following variants: #{unmatched_variants}"
        )
      end

      # Defining #_correct_variant_matcher "statically" allows us to use yield
      # instead of block.call, which is much faster in most ruby versions.
      # https://github.com/JuanitoFatas/fast-ruby/blob/256fa4916b577befb40ba5ffaa22af08dc16565c/README.md#proc--block
      def _correct_variant_matcher(value = nil)
        variant = self.class::VARIANT

        _ensure_wildcard_not_matched!(variant)
        _ensure_no_duplicate_match!(variant)

        @matched_variants << variant
        @matched = true

        @result =
          if block_given?
            yield(*@variant_instance.members(dup: false))
          else
            value
          end

        self
      end

      def _ensure_wildcard_not_matched!(variant)
        return unless @wildcard_matched

        raise(
          MatchAfterWildcardError,
          "Attempted to match variant after wildcard (_): #{variant}"
        )
      end

      def _ensure_no_duplicate_match!(variant)
        return unless @matched_variants.include?(variant)

        raise(DuplicateMatchError, "Duplicated match for variant: #{variant}")
      end
    end
  end
end
