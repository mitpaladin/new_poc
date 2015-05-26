
require 'spec_helper'

describe IndexRowBuilder, type: :request do
  before :each do
    Time.zone = 'Asia/Singapore'
  end

  describe 'supports initialisation with' do
    it 'two required parameters' do
      expected = Regexp.new Regexp.escape('wrong number of arguments (0 for 2)')
      expect { described_class.new }.to raise_error ArgumentError, expected
    end

    describe 'two parameters, where' do
      it 'the first parameter is an integer' do
        first_param_message = /violation for argument 1 of 2/
        expect { described_class.new 1, 'bogus' }.to raise_error do |e|
          expect(e).to be_a ParamContractError
          expect(e.message).not_to match first_param_message
        end
        expect { described_class.new 'bad', 'bogus' }.to raise_error do |e|
          expect(e).to be_a ParamContractError
          expect(e.message).to match first_param_message
        end
      end

      it 'the second parameter responds to the :name message' do
        valid_param = FancyOpenStruct.new name: 'A Name'
        expect { described_class.new 1, valid_param }.not_to raise_error
        expect { described_class.new 1, 'A Name' }.to raise_error do |e|
          expect(e).to be_a ParamContractError
          expect(e.message).to match(/violation for argument 2 of 2/)
        end
      end
    end # describe 'two parameters, where'
  end # describe 'supports initialisation with'

  describe 'has a #build method that' do
    let(:default_user) { FactoryGirl.build_stubbed :user, :saved_user }
    let(:default_count) { 5 }
    let(:obj) { described_class.new default_count, default_user }

    it 'requires one parameter' do
      expect { obj.build }.to raise_error ArgumentError, /0 for 1/
    end

    describe 'requires a parameter that responds to the message' do
      after :each do
        attr_name = RSpec.current_example.description[1..-1]
        attr = attr_name.to_sym
        target_attribs = default_user.attributes.symbolize_keys
                         .reject { |k, _v| k == attr }
        target_user = FancyOpenStruct.new target_attribs
        expect { obj.build target_user }.to raise_error do |e|
          expect(e).to be_a ParamContractError
          actual_line = e.message.lines.find { |l| l.match(/Actual: /) }
          expect(actual_line).not_to match(/#{attr_name}=/)
          expected_line = e.message.lines.find { |l| l.match(/Expected: /) }
          expect(expected_line).to match ":#{attr_name}"
        end
      end

      it ':created_at' do
      end

      it ':name' do
      end

      it ':slug' do
      end
    end # describe 'requires a parameter that responds to the message'

    context 'when the target user is the current user' do
      let(:actual) { obj.build default_user }

      fit 'returns an HTML table row' do
        expect(actual).to match %r{\A<tr.+</tr>\z}
      end

      describe 'returns an HTML table row that' do
        let(:matches) do
          actual.match %r{<td>(.+?)</td><td>(\d+)</td><td>(.+?)</td>}
        end

        it 'has a "class" attribute defined' do
          expect(actual).to match %r{\A<tr class="info">.+</tr>\z}
        end

        it 'encloses 3 :td tag pairs' do
          expect(actual).to match %r{(<td>.+</td>){3}}
        end

        describe 'includes within its' do
          describe 'first :td tag pair' do
            describe 'an HTML :a tag pair specifying' do
              it 'a link to the user profile page' do
                path = user_path(default_user)
                expect(matches[1]).to match %r{<a href="#{path}">.+</a>}
              end

              it 'the user name as the link text' do
                expect(matches[1]).to match %r{<a.+?>#{default_user.name}</a>}
              end
            end # describe 'an HTML :a tag pair specifying'
          end # describe 'first :td tag pair'

          describe 'second :td tag pair' do
            it 'the specified number of posts' do
              expect(matches[2].to_i).to eq default_count
            end
          end # describe 'second :td tag pair'

          describe 'third :td tag pair' do
            it 'a representation of the user created-at timestamp' do
              stamp = Time.zone.parse matches[3]
              expect(stamp).to be_within(59.seconds).of default_user.created_at
            end
          end # describe 'third :td tag pair'
        end # describe 'includes within its'
      end # describe 'returns an HTML table row that'
    end # context 'when the target user is the current user'

    context 'when the target user is NOT the current user' do
      let(:actual) { obj.build target_user }
      let(:target_user) { FactoryGirl.build_stubbed :user, :saved_user }

      describe 'returns an HTML table row that' do
        let(:matches) do
          actual.match %r{<td>(.+?)</td><td>(\d+)</td><td>(.+?)</td>}
        end

        it 'DOES NOT have any attributes defined' do
          expect(actual).to match %r{\A<tr>.+</tr>\z}
        end

        describe 'includes within its' do
          describe 'first :td tag pair' do
            describe 'an HTML :a tag pair specifying' do
              it 'a link to the target user profile page' do
                path = user_path(target_user)
                expect(matches[1]).to match %r{<a href="#{path}">.+</a>}
              end

              it 'the target user name as the link text' do
                expect(matches[1]).to match %r{<a.+?>#{target_user.name}</a>}
              end
            end # describe 'an HTML :a tag pair specifying'
          end # describe 'first :td tag pair'
        end # describe 'includes within its'
      end # describe 'returns an HTML table row that'
    end # context 'when the target user is NOT the current user'
  end # describe 'has a #build method that'
end
