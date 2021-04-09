# frozen_string_literal: true

module SumsUp
  module Core
    # SumTypes are just modules with a meta-programmed methods to construct
    # variants. Use SumType.build to define a new one.
    #
    # Each variant class must have the following constants defined:
    #
    # * VARIANT - Symbol name of the variant
    # * MEMBERS - Array of Symbols which enumerate the variant's arguments
    #
    class SumType < Module
      private_class_method :new

      def self.build(variant_classes)
        new do
          const_set(:VARIANTS, variant_classes.freeze)

          variant_classes.each do |variant_class|
            variant_name = variant_class.const_get(:VARIANT)
            class_name = SumType.variant_class_name(variant_name)
            initializer = SumType.variant_initializer(variant_class)

            const_set(class_name, variant_class)
            define_singleton_method(variant_name, &initializer)

            variant_class.include(self)
          end
        end
      end

      def self.variant_class_name(variant_name)
        Strings
          .snake_to_class(variant_name.to_s)
          .to_sym
      end

      # Variants without any members are frozen by default for performance.
      # Pass `memo: false` to its initializer to opt out of this behavior:
      #
      #   Maybe = SumsUp.define(:nothing, just: :value)
      #
      #   frozen_nothing = Maybe.nothing
      #   unfrozen_nothing = Maybe.nothing(memo: false)
      #
      #   # Variants with members are never frozen.
      #   unfrozen_just = Maybe.just(1)
      #
      def self.variant_initializer(variant_class)
        if variant_class.const_get(:MEMBERS).empty?
          dup_if_overridden(variant_class.new.freeze)
        else
          variant_class.method(:new)
        end
      end

      def self.dup_if_overridden(frozen)
        proc do |memo: true|
          memo ? frozen : frozen.dup
        end
      end
    end
  end
end
