# frozen_string_literal: true

RSpec.describe SumsUp::Core::Functions do
  describe '.const' do
    it 'generates a function which always returns the same value' do
      func = subject.const(42)

      expect(func.call)
        .to(eq(42))

      100.times do
        expect(func.call)
          .to(eq(42))
      end
    end
  end
end
