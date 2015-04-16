
require 'spec_helper'

require 'post/validators/title'

# Namespace containing all application-defined entities.
module Entity
  describe Post::Validators::Title do
    let(:attributes) { FancyOpenStruct.new title: title }
    let(:obj) { described_class.new attributes }

    context 'when initialised with attributes including a valid title' do
      let(:title) { 'Valid Title' }

      it 'is recognised as valid' do
        expect(obj).to be_valid
      end

      it 'has no errors' do
        expect(obj).to have(0).errors
      end
    end # context 'when initialised with attributes including a valid title'

    context 'when initialised with a title that is invalid because it' do
      context 'is missing, it' do
        let(:title) { nil }

        it 'is recognised as not valid' do
          expect(obj).not_to be_valid
        end

        it 'has one error' do
          expect(obj).to have(1).error
        end

        it 'reports that the title must be present' do
          expected = { title: 'must be present' }
          expect(obj.errors.first).to eq expected
        end
      end # context 'is missing, it'

      context 'is blank, it' do
        let(:title) { '   ' }

        it 'is recognised as not valid' do
          expect(obj).not_to be_valid
        end

        it 'has one error' do
          expect(obj).to have(1).error
        end

        it 'reports that the title must not be blank' do
          expected = { title: 'must not be blank' }
          expect(obj.errors.first).to eq expected
        end
      end # context 'is blank, it'

      context 'contains whitespace' do
        context 'at the start of the title' do
          let(:title) { '  A Title' }

          it 'is recognised as invalid' do
            expect(obj).not_to be_valid
          end

          it 'reports a single error' do
            expect(obj).to have(1).error
          end

          it 'reports that the title must not have leading whitespace' do
            expected = { title: 'must not have leading whitespace' }
            expect(obj.errors.first).to eq expected
          end
        end # context 'at the start of the title'

        context 'at the end of the title' do
          let(:title) { 'A Title  ' }

          it 'is recognised as invalid' do
            expect(obj).not_to be_valid
          end

          it 'reports a single error' do
            expect(obj).to have(1).error
          end

          it 'reports that the title must not have trailing whitespace' do
            expected = { title: 'must not have trailing whitespace' }
            expect(obj.errors.first).to eq expected
          end
        end # context 'at the end of the title'

        context 'in adjacent positions within the title' do
          let(:title) { 'A     Title' }

          it 'is recognised as invalid' do
            expect(obj).not_to be_valid
          end

          it 'reports a single error' do
            expect(obj).to have(1).error
          end

          it 'reports that the title must not have extra whitespace' do
            expected = { title: 'must not have extra internal whitespace' }
            expect(obj.errors.first).to eq expected
          end
        end # context 'in adjacent positions within the title'
      end # context 'contains whitespace'

      context 'has multiple errors' do
        let(:title) { "\nAn  Invalid Title\tIs Here   " }

        it 'is recognised as invalid' do
          expect(obj).not_to be_valid
        end

        it 'reports three errors' do
          expect(obj).to have(3).error
        end

        it 'reports each type of invalid whitespace in the title' do
          [
            { title: 'must not have leading whitespace' },
            { title: 'must not have trailing whitespace' },
            { title: 'must not have leading whitespace' }
          ].each do |expected|
            expect(obj.errors).to include expected
          end
        end
      end # context 'has multiple errors'
    end # context 'when initialised with a title that is invalid because it'
  end # describe Post::Validators::Title
end
