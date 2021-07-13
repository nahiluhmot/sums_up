# frozen_string_literal: true

RSpec.describe SumsUp::Result do
  describe '.from_block' do
    context 'given no arguments' do
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

    context 'given an error class' do
      let(:error_class) { Class.new(StandardError) }

      it 'propagates the error when the block raises a different error' do
        other_class = Class.new(StandardError)

        expect { SumsUp::Result.from_block(error_class) { raise other_class } }
          .to(raise_error(other_class))
      end

      it 'wraps the error when the block raises that error' do
        error_instance = error_class.new('something went wrong')

        expect(SumsUp::Result.from_block(error_class) { raise(error_instance) })
          .to(eq(SumsUp::Result.failure(error_instance)))
      end

      it 'wraps the result when the block does not raise' do
        result = double(:result)

        expect(SumsUp::Result.from_block { result })
          .to(eq(SumsUp::Result.success(result)))
      end
    end
  end

  describe '#to_s' do
    it 'uses the class name' do
      expect(SumsUp::Result.success('oh good').to_s)
        .to(eq('#<variant SumsUp::Result::Success value="oh good">'))

      expect(SumsUp::Result.failure('oh no').to_s)
        .to(eq('#<variant SumsUp::Result::Failure error="oh no">'))
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
