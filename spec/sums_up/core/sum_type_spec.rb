# frozen_string_literal: true

RSpec.describe SumsUp::Core::SumType do
  # Maybe-like example type.
  subject do
    described_class.build(classes).module_eval do
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

      self
    end
  end

  let(:classes) { [nothing_variant_class, just_variant_class] }
  let(:nothing_variant_class) do
    Class.new do
      const_set(:VARIANT, :nothing)
      const_set(:MEMBERS, [])

      define_method(:==) { |other| other.is_a?(self.class) }
    end
  end
  let(:just_variant_class) do
    Class.new do
      const_set(:VARIANT, :just)
      const_set(:MEMBERS, %i[value])

      attr_reader(:value)

      define_method(:initialize) { |value| @value = value }
      define_method(:==) do |other|
        other.is_a?(self.class) && (other.value == value)
      end
    end
  end

  describe 'no-arg variant consturctors' do
    it 'returns the same object every time unless overridden' do
      nothing_instance = subject.nothing
      duped_instance = subject.nothing(memo: false)

      expect(nothing_instance)
        .to(be_a(nothing_variant_class))
      expect(duped_instance)
        .to(be_a(nothing_variant_class))

      expect(nothing_instance)
        .to(eq(nothing_variant_class.new))
      expect(duped_instance)
        .to(eq(nothing_variant_class.new))

      expect(nothing_instance)
        .to_not(eq(subject.just(1)))
      expect(duped_instance)
        .to_not(eq(subject.just(1)))

      expect(nothing_instance)
        .to(equal(subject.nothing))
      expect(duped_instance)
        .to_not(equal(subject.nothing))

      expect(nothing_instance)
        .to_not(equal(nothing_variant_class.new))
      expect(duped_instance)
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
