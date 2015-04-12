
require 'spec_helper'

require 'post/validators/author_name'

# Namespace containing all application-defined entities.
module Entity
  describe Post::Validators::AuthorName do
    let(:attributes) { FancyOpenStruct.new author_name: author_name }
    let(:obj) { described_class.new attributes }

    context 'when initialised with attributes including a valid author name' do
      let(:author_name) { 'Some Author' }

      it 'is recognised as valid' do
        expect(obj).to be_valid
      end

      it 'has no errors' do
        expect(obj).to have(0).errors
      end
    end # context 'when initialised with attributes ... a valid author name'

    context 'when initialised with an author name that is invalid because it' do
      context 'is missing, it' do
        let(:author_name) { nil }

        it 'is recognised as not valid' do
          expect(obj).not_to be_valid
        end

        it 'has one error' do
          expect(obj).to have(1).error
        end

        it 'reports that the author name must be present' do
          expected = { author_name: 'must be present' }
          expect(obj.errors.first).to eq expected
        end
      end # context 'is missing, it'

      context 'is blank, it' do
        let(:author_name) { '   ' }

        it 'is recognised as not valid' do
          expect(obj).not_to be_valid
        end

        it 'has one error' do
          expect(obj).to have(1).error
        end

        it 'reports that the author name must not be blank' do
          expected = { author_name: 'must not be blank' }
          expect(obj.errors.first).to eq expected
        end
      end # context 'is blank, it'

      context 'contains whitespace' do
        context 'at the start of the author name, it' do
          let(:author_name) { '   The Author' }

          it 'is recognised as not valid' do
            expect(obj).not_to be_valid
          end

          it 'has one error' do
            expect(obj).to have(1).error
          end

          desc = 'reports that the author name must not contain leading' \
            ' whitespace'
          it desc do
            expected = { author_name: 'must not contain leading whitespace' }
            expect(obj.errors.first).to eq expected
          end
        end # context 'at the start of the author name, it'

        context 'at the end of the author name, it' do
          let(:author_name) { 'The Author     ' }

          it 'is recognised as not valid' do
            expect(obj).not_to be_valid
          end

          it 'has one error' do
            expect(obj).to have(1).error
          end

          desc = 'reports that the author name must not contain trailing' \
            ' whitespace'
          it desc do
            expected = { author_name: 'must not contain trailing whitespace' }
            expect(obj.errors.first).to eq expected
          end
        end # context 'at the end of the author name, it'

        context 'consecutively within the author name, it' do
          let(:author_name) { 'The         Author' }

          it 'is recognised as not valid' do
            expect(obj).not_to be_valid
          end

          it 'has one error' do
            expect(obj).to have(1).error
          end

          desc = 'reports that the author name must not contain consecutive' \
            ' whitespace'
          it desc do
            expected = {
              author_name: 'must not have consecutive internal whitespace'
            }
            expect(obj.errors.first).to eq expected
          end
        end # context 'consecutively within the author name, it'
      end # context 'contains whitespace'

      context 'names the Guest User' do
        let(:author_name) { 'Guest User' }

        it 'is recognised as not valid' do
          expect(obj).not_to be_valid
        end

        it 'has one error' do
          expect(obj).to have(1).error
        end

        it 'reports that the author name must be that of a registered user' do
          expected = { author_name: 'must be a registered user' }
          expect(obj.errors.first).to eq expected
        end
      end # context 'names the Guest User' do
    end # context 'when initialised with an author name ... invalid because it'
  end # describe Post::Validators::AuthorName
end
