# == Schema Information
#
# Table name: user_data
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  email      :string(255)      not null
#  profile    :text
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe UserData do

  describe :registered?.to_s do

    it 'returns false for the Guest User' do
      name = UserData.guest_user_name
      user = FactoryGirl.build :user_datum, name: name
      expect(user).to_not be_registered
    end

    it 'returns true for a registered user' do
      expect(FactoryGirl.build :user_datum).to be_registered
    end
  end # describe :registered?.to_s
end
