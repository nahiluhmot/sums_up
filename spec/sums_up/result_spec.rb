# frozen_string_literal: true

RSpec.describe SumsUp::Result do
  describe '.from_block' do
    it 'wraps the error when the block raises' do
      err = StandardError.new

      expect(SumsUp::Result.from_block { raise(err) })
        .to(eq(SumsUp::Result.failure(err)))
    end

    it 'wraps the result when the block does not raise' do
      result = double(:result)

      expect(SumsUp::Result.from_block { result })
        .to(eq(SumsUp::Result.success(result)))
    end
  end

  describe '#map' do
    it 'yields the value and re-wraps the result on success' do
      expect(
        SumsUp::Result
          .success('tsud eht setib eno rehtona')
          .map(&:reverse)
      ).to(eq(SumsUp::Result.success('another one bites the dust')))
    end

    it 'returns self on failure' do
      expect(
        SumsUp::Result
          .failure(:err)
          .map(&:this_will_never_execute)
      ).to(eq(SumsUp::Result.failure(:err)))
    end
  end

  describe '#map_failure' do
    it 'returns self on success' do
      expect(
        SumsUp::Result
          .success('great')
          .map_failure(&:this_will_never_execute)
      ).to(eq(SumsUp::Result.success('great')))
    end

    it 'yields the error and re-wraps the result on failure' do
      expect(
        SumsUp::Result
          .failure(StandardError.new('failed successfully'))
          .map_failure(&:message)
      ).to(eq(SumsUp::Result.failure('failed successfully')))
    end
  end
end
