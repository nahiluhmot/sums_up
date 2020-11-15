# frozen_string_literal: true

module SumsUp
  module Core
    # Represents a variant of a sumtype. Use build_variant_class to generate
    # a new subclass for a given variant.
    class Variant
      def self.build_variant_class(name, other_names, members)
        Class.new(self).tap do |variant_class|
          variant_class.const_set(:VARIANT, name)
          variant_class.const_set(:MEMBERS, members)

          variant_class.const_set(:Accessors, accessors_module(members))
          variant_class.const_set(
            :Predicates,
            predicates_module(name, other_names)
          )

          variant_class.include(variant_class.const_get(:Accessors))
          variant_class.include(variant_class.const_get(:Predicates))
        end
      end

      def self.accessors_module(members)
        Module.new.tap do |mod|
          members.each_with_index do |member, idx|
            mod.define_method(member) { @values[idx] }

            mod.define_method(:"#{member}=") { |val| @values[idx] = val }
          end
        end
      end

      def self.predicates_module(correct_name, incorrect_names)
        Module.new.tap do |mod|
          mod.define_method(:"#{correct_name}?", &Functions.const(true))

          incorrect_names.each do |incorrect_name|
            mod.define_method(:"#{incorrect_name}?", &Functions.const(false))
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

      def to_s
        io = StringIO.new
        io << "#<variant #{self.class::VARIANT}"

        self.class::MEMBERS.each_with_index do |member, idx|
          io << (idx.zero? ? ' ' : ', ')
          io << "#{member}=#{@values[idx]}"
        end

        io << '>'

        io.string
      end

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