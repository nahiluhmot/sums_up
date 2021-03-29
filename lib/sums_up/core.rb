# frozen_string_literal: true

require 'sums_up/core/functions'
require 'sums_up/core/matcher'
require 'sums_up/core/parser'
require 'sums_up/core/strings'
require 'sums_up/core/sum_type'
require 'sums_up/core/variant'

module SumsUp
  # Core functionality which builds modules for sum types and classes for
  # variants.
  module Core
    module_function

    def define(*no_arg_variants, **arg_variants, &block)
      variant_specs = Parser.parse_variant_specs!(no_arg_variants, arg_variants)
      variant_names = variant_specs.keys

      variant_classes = variant_specs.map do |name, members|
        others = variant_names - [name]
        matcher_class = Matcher.build_matcher_class(name, others)

        Variant.build_variant_class(name, others, members, matcher_class)
      end

      SumType
        .build(variant_classes)
        .tap { |sum_type| sum_type.module_eval(&block) }
    end
  end
end
