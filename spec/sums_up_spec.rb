# frozen_string_literal: true

RSpec.describe SumsUp do
  describe '.define' do
    it 'raises given malformed variant' do
      expect { subject.define('string', 'args') }
        .to(raise_error(SumsUp::ParserError))
    end

    it 'builds a sum type given only no-arg variants' do
      color = subject.define(:red, :green, :blue) do
        def not_blue?
          match do |m|
            m.blue false
            m._ true
          end
        end
      end

      expect(color.red.to_s)
        .to((eq('#<variant red>')))

      expect(color.green)
        .to(be_not_blue)

      expect(color.blue)
        .to_not(be_not_blue)
    end

    it 'builds a sum type given only arg variants' do
      either = subject.define(left: :value, right: :value) do
        def self.from_block
          right(yield)
        rescue StandardError => e
          left(e)
        end
      end

      expect(either.left('uh oh').to_s)
        .to(eq('#<variant left value=uh oh>'))

      expect(either.from_block { 'yay' }[:value])
        .to(eq('yay'))

      err = StandardError.new

      expect(either.from_block { raise err })
        .to(eq(either.left(err)))
    end

    it 'builds a sum type given both arg and no-arg variants' do
      list = subject.define(:empty, cons: %i[car cdr]) do
        def self.from_array(ary)
          ary.reverse_each.reduce(empty) do |list, ele|
            cons(ele, list)
          end
        end
      end

      expect(list.from_array([1, 2, 3]))
        .to(eq(list.cons(1, list.cons(2, list.cons(3, list.empty)))))
    end
  end
end
