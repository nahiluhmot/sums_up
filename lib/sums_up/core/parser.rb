# frozen_string_literal: true

module SumsUp
  module Core
    # Validates and normalizes arguments passed to SumsUp.define.
    module Parser
      LOWER_SNAKE_CASE_REGEXP = /\A[[:lower:]]+(_[[:lower:]]+)*\z/.freeze

      module_function

      def parse_variant_specs!(no_arg_variants, arg_variants)
        variant_names = no_arg_variants + arg_variants.keys

        validate_unique!(variant_names)
        variant_names.each(&method(:validate_name_format!))
        arg_variants.each_value(&method(:validate_variant_args!))

        no_arg_variants
          .map { |variant| [variant, []] }
          .to_h
          .merge(arg_variants.map { |key, ary| [key, [*ary]] }.to_h)
      end

      def validate_unique!(variant_names)
        duplicates = variant_names
          .group_by(&:itself)
          .select { |_, values| values.length > 1 }
          .keys

        return if duplicates.empty?

        raise(
          DuplicateNameError,
          "Duplicated names: #{duplicates.join(', ')}"
        )
      end

      def validate_name_format!(variant_name)
        unless variant_name.is_a?(Symbol)
          raise(VariantNameError, "Expected a Symbol, got: #{variant_name}")
        end

        return if LOWER_SNAKE_CASE_REGEXP.match(variant_name.to_s)

        raise(
          VariantNameError,
          "Name is not lower_snake_case: #{variant_name}"
        )
      end

      def validate_variant_args!(variant_args)
        case variant_args
        when Symbol
          validate_name_format!(variant_args)
        when Array
          variant_args.each(&method(:validate_name_format!))

          validate_unique!(variant_args)
        else
          raise(
            VariantArgsError,
            "Expected a Symbol or Array, got: #{variant_args}"
          )
        end
      end
    end
  end
end
