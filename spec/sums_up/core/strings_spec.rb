# frozen_string_literal: true

RSpec.describe SumsUp::Core::Strings do
  describe '.snake_to_class' do
    it 'translates snake_case names to ClassCase' do
      expect(subject.snake_to_class('some_name'))
        .to(eq('SomeName'))
    end
  end
end
