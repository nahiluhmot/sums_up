# frozen_string_literal: true

module SumsUp
  module Core
    # Represents a variant of a sumtype. Use build_variant_class to generate
    # a new subclass for a given variant.
    class Variant
      def self.build_variant_class(name, other_names, members, matcher_class)
        Class.new(self) do
          const_set(:VARIANT, name)
          const_set(:MEMBERS, members.freeze)

          const_set(:Accessors, accessors_module(members))
          const_set(:Matcher, matcher_class)
          const_set(:Predicates, predicates_module(name, other_names))

          include(const_get(:Accessors))
          include(const_get(:Predicates))
        end
      end

      def self.accessors_module(members)
        Module.new do
          members.each_with_index do |member, idx|
            define_method(member) { @values[idx] }

            define_method(:"#{member}=") { |val| @values[idx] = val }
          end
        end
      end

      def self.predicates_module(correct_name, incorrect_names)
        Module.new do
          define_method(:"#{correct_name}?", &Functions.const(true))

          incorrect_names.each do |incorrect_name|
            define_method(:"#{incorrect_name}?", &Functions.const(false))
          end
        end
      end

      def initialize(*values)
        given = values.length
        expected = self.class::MEMBERS.length

        if given != expected
          raise(
            ArgumentError,
            "wrong number of arguments (given #{given}, expected #{expected})"
          )
        end

        @values = values
      end

      def [](key)
        idx = index_for_key(key)

        @values[idx]
      end

      def []=(key, val)
        idx = index_for_key(key)

        @values[idx] = val
      end

      def match(**kwargs)
        matcher = self.class::Matcher.new(self)

        if block_given?
          yield(matcher)
        else
          matcher._match_hash(kwargs)
        end

        matcher._fetch_result
      end

      def members(dup: true)
        if dup
          @values.dup
        else
          @values
        end
      end

      alias to_a members

      def attributes
        self.class::MEMBERS.zip(@values).to_h
      end

      def to_h(include_root: true)
        if include_root
          { self.class::VARIANT => attributes }
        else
          attributes
        end
      end

      def inspect
        # If a sum type is defined but not assigned to a constant, Class.name
        # name will return nil in Ruby 2.
        variant = self.class.name || self.class::VARIANT

        attrs = self.class::MEMBERS
          .zip(@values)
          .map { |member, value| "#{member}=#{value.inspect}" }
          .join(', ')

        if attrs.empty?
          "#<variant #{variant}>"
        else
          "#<variant #{variant} #{attrs}>"
        end
      end

      alias to_s inspect

      def ==(other)
        other.is_a?(self.class) &&
          (other.to_a(dup: false) == @values)
      end

      private

      def index_for_key(key)
        idx = self.class::MEMBERS.index(key.to_sym)

        return idx if idx

        raise(NameError, "No member '#{key}' in variant #{self.class::VARIANT}")
      end
    end
  end
end
