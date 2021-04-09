# frozen_string_literal: true

RSpec.describe SumsUp::Core::Parser do
  describe '.parse_variant_specs!' do
    context 'given no-arg variants which are not symbols' do
      let(:no_arg_variants) { %w[not_symbol] }
      let(:arg_variants) { {} }

      it 'raises' do
        expect { subject.parse_variant_specs!(no_arg_variants, arg_variants) }
          .to(
            raise_error(
              SumsUp::VariantNameError,
              'Expected a Symbol, got: not_symbol'
            )
          )
      end
    end

    context 'given arg variants which are not symbols' do
      let(:no_arg_variants) { [] }
      let(:arg_variants) { { 'not_symbol' => %i[value] } }

      it 'raises' do
        expect { subject.parse_variant_specs!(no_arg_variants, arg_variants) }
          .to(
            raise_error(
              SumsUp::VariantNameError,
              'Expected a Symbol, got: not_symbol'
            )
          )
      end
    end

    context 'given arguments which are not symbols' do
      let(:no_arg_variants) { [] }
      let(:arg_variants) { { symbol: %w[not symbols] } }

      it 'raises' do
        expect { subject.parse_variant_specs!(no_arg_variants, arg_variants) }
          .to(
            raise_error(
              SumsUp::VariantNameError,
              'Expected a Symbol, got: not'
            )
          )
      end
    end

    context 'given no-arg variants which are not lower_snake_case' do
      let(:no_arg_variants) { %i[CamelCase] }
      let(:arg_variants) { {} }

      it 'raises' do
        expect { subject.parse_variant_specs!(no_arg_variants, arg_variants) }
          .to(
            raise_error(
              SumsUp::VariantNameError,
              'Name is not lower_snake_case: CamelCase'
            )
          )
      end
    end

    context 'given arg variants which are not lower_snake_case' do
      let(:no_arg_variants) { [] }
      let(:arg_variants) { { _prefixed_with_underscore: [] } }

      it 'raises' do
        expect { subject.parse_variant_specs!(no_arg_variants, arg_variants) }
          .to(
            raise_error(
              SumsUp::VariantNameError,
              'Name is not lower_snake_case: _prefixed_with_underscore'
            )
          )
      end
    end

    context 'given arguments which are not lower_snake_case' do
      let(:no_arg_variants) { [] }
      let(:arg_variants) { { snake_case: %i[suffixed_with_underscore_] } }

      it 'raises' do
        expect { subject.parse_variant_specs!(no_arg_variants, arg_variants) }
          .to(
            raise_error(
              SumsUp::VariantNameError,
              'Name is not lower_snake_case: suffixed_with_underscore_'
            )
          )
      end
    end

    context 'given duplicated no-arg variants' do
      let(:no_arg_variants) { %i[dup dup] }
      let(:arg_variants) { {} }

      it 'raises' do
        expect { subject.parse_variant_specs!(no_arg_variants, arg_variants) }
          .to(
            raise_error(
              SumsUp::DuplicateNameError,
              'Duplicated names: dup'
            )
          )
      end
    end

    context 'given duplicated arg and no-arg variants' do
      let(:no_arg_variants) { %i[dup] }
      let(:arg_variants) { { dup: [] } }

      it 'raises' do
        expect { subject.parse_variant_specs!(no_arg_variants, arg_variants) }
          .to(
            raise_error(
              SumsUp::DuplicateNameError,
              'Duplicated names: dup'
            )
          )
      end
    end

    context 'given duplicated arguments in a variant' do
      let(:no_arg_variants) { [] }
      let(:arg_variants) { { variant_name: %i[arg arg] } }

      it 'raises' do
        expect { subject.parse_variant_specs!(no_arg_variants, arg_variants) }
          .to(
            raise_error(
              SumsUp::DuplicateNameError,
              'Duplicated names: arg'
            )
          )
      end
    end

    context 'given only arg variants' do
      let(:no_arg_variants) { [] }
      let(:arg_variants) { { left: :value, right: %i[value] } }

      it 'returns the normalized variant specs' do
        expect(subject.parse_variant_specs!(no_arg_variants, arg_variants))
          .to(eq(left: %i[value], right: %i[value]))
      end
    end

    context 'given only no-arg variants' do
      let(:no_arg_variants) { %i[red green blue] }
      let(:arg_variants) { {} }

      it 'returns the normalized variant specs' do
        expect(subject.parse_variant_specs!(no_arg_variants, arg_variants))
          .to(eq(red: [], green: [], blue: []))
      end
    end

    context 'given both arg and no arg variants' do
      let(:no_arg_variants) { %i[one two] }
      let(:arg_variants) { { three: :value, four: %i[alpha beta] } }

      it 'returns the normalized variant specs' do
        expect(subject.parse_variant_specs!(no_arg_variants, arg_variants))
          .to(eq(one: [], two: [], three: %i[value], four: %i[alpha beta]))
      end
    end
  end
end
