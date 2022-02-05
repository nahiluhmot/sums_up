# frozen_string_literal: true

module SumsUp
  # Test types for exercising .define.
  module TestTypes
    Color = SumsUp.define(:red, :green, :blue) do
      def not_blue?
        match(blue: false, _: true)
      end
    end

    Either = SumsUp.define(left: :value, right: :value) do
      def self.from_block
        right(yield)
      rescue => e
        left(e)
      end

      def map
        match do |m|
          m.right { |value| Either.right(yield(value)) }
          m.left self
        end
      end
    end

    List = SumsUp.define(:empty, cons: %i[car cdr]) do
      def self.from_array(ary)
        ary.reverse_each.reduce(empty) do |list, ele|
          cons(ele, list)
        end
      end
    end
  end
end
