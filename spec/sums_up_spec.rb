# frozen_string_literal: true

RSpec.describe SumsUp do
  # Require the test types in a before (as opposed to at the top of the file)
  # so that issues with SumsUp.define don't prevent the rest of the specs from
  # running.
  before { require 'sums_up/test_types' }

  describe '.define' do
    it 'raises given malformed variant' do
      expect { subject.define('string', 'args') }
        .to(raise_error(SumsUp::ParserError))
    end

    it 'builds a sum type given only no-arg variants' do
      expect(SumsUp::TestTypes::Color.red.to_s)
        .to(eq('#<variant SumsUp::TestTypes::Color::Red>'))

      expect(SumsUp::TestTypes::Color.red)
        .to(be_not_blue)

      expect(SumsUp::TestTypes::Color.green)
        .to(be_not_blue)

      expect(SumsUp::TestTypes::Color.blue)
        .to_not(be_not_blue)
    end

    it 'builds a sum type given only arg variants' do
      expect(SumsUp::TestTypes::Either.left('uh oh').to_s)
        .to(eq('#<variant SumsUp::TestTypes::Either::Left value="uh oh">'))

      expect(SumsUp::TestTypes::Either.from_block { 'yay' }[:value])
        .to(eq('yay'))

      expect(SumsUp::TestTypes::Either.right(1).map(&:succ))
        .to(eq(SumsUp::TestTypes::Either.right(2)))

      expect(SumsUp::TestTypes::Either.left(1).map(&:to_s))
        .to(eq(SumsUp::TestTypes::Either.left(1)))

      err = StandardError.new

      expect(SumsUp::TestTypes::Either.from_block { raise err })
        .to(eq(SumsUp::TestTypes::Either.left(err)))
    end

    it 'builds a sum type given both arg and no-arg variants' do
      expect(SumsUp::TestTypes::List.from_array([1, 2, 3])).to(
        eq(
          SumsUp::TestTypes::List.cons(
            1,
            SumsUp::TestTypes::List.cons(
              2,
              SumsUp::TestTypes::List.cons(
                3,
                SumsUp::TestTypes::List.empty
              )
            )
          )
        )
      )
    end
  end
end
