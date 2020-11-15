# frozen_string_literal: true

RSpec.describe SumsUp::Core::Matcher do
  let(:subject) { matcher_class.new(variant_instance) }

  let(:matcher_class) do
    described_class.build_matcher_class(:just, %i[nothing])
  end
  let(:variant_instance) { double(:just, members: [128]) }

  describe 'matching' do
    context 'when there are duplicate instances of the matched variant' do
      before do
        subject.just(1)
        subject.nothing(0)
      end

      it 'raises' do
        expect { subject.just { |value| value * 2 } }.to(
          raise_error(
            SumsUp::DuplicateMatchError,
            'Duplicated match for variant: just'
          )
        )
      end
    end

    context 'when there are duplicate instances of an unmatched variant' do
      before do
        subject.just { |value| value }
        subject.nothing { 1 }
      end

      it 'raises' do
        expect { subject.nothing(0) }.to(
          raise_error(
            SumsUp::DuplicateMatchError,
            'Duplicated match for variant: nothing'
          )
        )
      end
    end

    context 'when the matched variant appears after a wildcard matcher' do
      before { subject._ { 2 } }

      it 'raises' do
        expect { subject.just { notify_the_secret_service } }.to(
          raise_error(
            SumsUp::MatchAfterWildcardError,
            'Attempted to match variant after wildcard (_): just'
          )
        )
      end
    end

    context 'when an unmatched variant appears after a wildcard matcher' do
      before { subject._(0) }

      it 'raises' do
        expect { subject.nothing { e_t_phone_home } }.to(
          raise_error(
            SumsUp::MatchAfterWildcardError,
            'Attempted to match variant after wildcard (_): nothing'
          )
        )
      end
    end

    context 'when the correct variant is not matched' do
      before { subject.nothing(0) }

      it 'raises' do
        expect { subject._fetch_result }.to(
          raise_error(
            SumsUp::UnmatchedVariantError,
            'Did not match the following variants: just'
          )
        )
      end
    end

    context 'when an incorrect variant is not matched' do
      before { subject.just(:the_world) }

      it 'raises' do
        expect { subject._fetch_result }.to(
          raise_error(
            SumsUp::UnmatchedVariantError,
            'Did not match the following variants: nothing'
          )
        )
      end
    end

    context 'when there is only a wildcard matcher' do
      before { subject._(42) }

      it 'returns the wildcard result' do
        expect(subject._fetch_result)
          .to(eq(42))
      end
    end

    context 'when all variants are explicitly matched' do
      context 'using chain syntax' do
        context 'using blocks' do
          before do
            subject
              .just { |value| value * 2 }
              .nothing { 0 }
          end

          it 'returns the matching result' do
            expect(subject._fetch_result)
              .to(eq(256))
          end
        end

        context 'not using blocks' do
          before do
            subject
              .just(:yep)
              .nothing(:nope)
          end

          it 'returns the matching result' do
            expect(subject._fetch_result)
              .to(eq(:yep))
          end
        end
      end

      context 'not using chain syntax' do
        context 'using blocks' do
          before do
            subject.just { |value| value / 2 }
            subject.nothing { 0 }
          end

          it 'returns the matching result' do
            expect(subject._fetch_result)
              .to(eq(64))
          end
        end

        context 'not using blocks' do
          before do
            subject.just(:car)
            subject.nothing(:cdr)
          end

          it 'returns the matching result' do
            expect(subject._fetch_result)
              .to(eq(:car))
          end
        end
      end
    end

    context 'when the correct variant is explicitly matched and a wildcard' do
      context 'using chain syntax' do
        context 'using blocks' do
          before do
            subject
              .just { |value| value * 2 }
              ._ { 0 }
          end

          it 'returns the matching result' do
            expect(subject._fetch_result)
              .to(eq(256))
          end
        end

        context 'not using blocks' do
          before do
            subject
              .just(:yep)
              ._(:nope)
          end

          it 'returns the matching result' do
            expect(subject._fetch_result)
              .to(eq(:yep))
          end
        end
      end

      context 'not using chain syntax' do
        context 'using blocks' do
          before do
            subject.just { |value| value / 2 }
            subject._ { 0 }
          end

          it 'returns the matching result' do
            expect(subject._fetch_result)
              .to(eq(64))
          end
        end

        context 'not using blocks' do
          before do
            subject.just(:car)
            subject._(:cdr)
          end

          it 'returns the matching result' do
            expect(subject._fetch_result)
              .to(eq(:car))
          end
        end
      end
    end

    context 'when incorrect variants are explicitly matched and a wildcard' do
      context 'using chain syntax' do
        context 'using blocks' do
          before do
            subject
              .nothing { 0 }
              ._ { 512 }
          end

          it 'returns the wildcard result' do
            expect(subject._fetch_result)
              .to(eq(512))
          end
        end

        context 'not using blocks' do
          before do
            subject
              .nothing(:nope)
              ._(:yep)
          end

          it 'returns the wildcard result' do
            expect(subject._fetch_result)
              .to(eq(:yep))
          end
        end
      end

      context 'not using chain syntax' do
        context 'using blocks' do
          before do
            subject.nothing { 0 }
            subject._ { 32 }
          end

          it 'returns the wildcard result' do
            expect(subject._fetch_result)
              .to(eq(32))
          end
        end

        context 'not using blocks' do
          before do
            subject.nothing(:cdr)
            subject._(:car)
          end

          it 'returns the wildcard result' do
            expect(subject._fetch_result)
              .to(eq(:car))
          end
        end
      end
    end
  end
end
