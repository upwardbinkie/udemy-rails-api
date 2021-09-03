# frozen_string_literal: true

require "rails_helper"

RSpec.describe(User, type: :model) do
  describe "#validations" do
    it "tests that factory is valid" do
      user = build(:user)
      expect(user).to(be_valid)
    end

    it "validates presence of attributes" do
      user = build(:user, login: nil, provider: nil)
      expect(user).not_to(be_valid)
      expect(user.errors.messages[:login]).to(include("can't be blank"))
      expect(user.errors.messages[:provider]).to(include("can't be blank"))
    end

    it "validates the uniqueness of login" do
      user = create(:user)
      other_user = build(:user, login: user.login)
      expect(other_user).not_to(be_valid)
      other_user.login = "new_login"
      expect(other_user).to(be_valid)
    end
  end
end
