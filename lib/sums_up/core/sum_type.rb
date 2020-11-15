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

      def self.build(variant_classes, &block)
        new(&block).tap do |sum_type|
          sum_type.const_set(:VARIANTS, variant_classes)

          variant_classes.each do |variant_class|
            variant_name = variant_class.const_get(:VARIANT)
            class_name = variant_class_name(variant_name)
            initializer = variant_initializer(variant_class)

            sum_type.const_set(class_name, variant_class)
            sum_type.define_singleton_method(variant_name, &initializer)

            variant_class.include(sum_type)
          end
        end
      end

      def self.variant_class_name(variant_name)
        Strings
          .snake_to_class(variant_name.to_s)
          .to_sym
      end

      def self.variant_initializer(variant_class)
        members = variant_class.const_get(:MEMBERS)

        if members.empty?
          Functions.const(variant_class.new)
        else
          variant_class.method(:new)
        end
      end
    end
  end
end
