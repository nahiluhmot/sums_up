# frozen_string_literal: true

RSpec.describe SumsUp::Core::SumType do
  subject { described_class.build(classes, &sum_type_initializer) }

  let(:classes) { [nothing_variant_class, just_variant_class] }
  let(:nothing_variant_class) do
    Class.new.tap do |klass|
      klass.const_set(:VARIANT, :nothing)
      klass.const_set(:MEMBERS, [])

      klass.define_method(:==) { |other| other.is_a?(self.class) }
    end
  end
  let(:just_variant_class) do
    Class.new.tap do |klass|
      klass.const_set(:VARIANT, :just)
      klass.const_set(:MEMBERS, %i[value])

      klass.attr_reader(:value)

      klass.define_method(:initialize) { |value| @value = value }
      klass.define_method(:==) do |other|
        other.is_a?(self.class) && (other.value == value)
      end
    end
  end
  let(:sum_type_initializer) do
    proc do
      def self.of(value)
        if value.nil?
          nothing
        else
          just(value)
        end
      end

      def or_else(other)
        respond_to?(:value) ? value : other
      end
    end
  end

  describe 'no-arg variant consturctors' do
    it 'returns the same object every time' do
      nothing_instance = subject.nothing

      expect(nothing_instance)
        .to(be_a(nothing_variant_class))

      expect(nothing_instance)
        .to(eq(nothing_variant_class.new))

      expect(nothing_instance)
        .to_not(eq(subject.just(1)))

      expect(nothing_instance)
        .to(equal(subject.nothing))

      expect(nothing_instance)
        .to_not(equal(nothing_variant_class.new))
    end
  end

  describe 'arg variant constructors' do
    it 'builds a new instance for each call' do
      just_instance = subject.just(1)

      expect(just_instance)
        .to(eq(just_variant_class.new(1)))

      expect(just_instance)
        .to_not(eq(just_variant_class.new(2)))

      expect(just_instance)
        .to_not(eq(subject.nothing))

      expect(just_instance)
        .to_not(equal(subject.just(1)))
    end
  end

  describe 'generated constants' do
    it 'sets constants for each class name' do
      expect(subject::Nothing)
        .to(eq(nothing_variant_class))

      expect(subject::Just)
        .to(eq(just_variant_class))
    end
  end

  describe 'class methods' do
    it 'can define custom class methods' do
      expect(subject)
        .to(respond_to(:of))

      expect(subject.of(nil))
        .to(eq(nothing_variant_class.new))

      expect(subject.of(:sym))
        .to(eq(just_variant_class.new(:sym)))
    end
  end

  describe 'instance methods' do
    it 'can define custom class methods' do
      nothing_instance = subject.nothing
      just_instance = subject.just('str')

      expect(nothing_instance)
        .to(respond_to(:or_else))

      expect(just_instance)
        .to(respond_to(:or_else))

      expect(nothing_instance.or_else('other'))
        .to(eq('other'))

      expect(just_instance.or_else('other'))
        .to(eq('str'))
    end
  end
end