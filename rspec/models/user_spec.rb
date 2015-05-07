require 'spec_helper'

describe User do
  let(:attrs) { FactoryGirl.attributes_for(:user) }
  subject(:user) { FactoryGirl.create(:user) }

  it "has a valid factory" do
    user = User.new(attrs)
    user.skip_confirmation_notification!
    user.save!
  end

  describe "#role_symbols" do
    context "when no roles assigned" do
      before do
        expect(Role.where(user: user)).to be_empty
      end

      it "is empty" do
        expect(user.role_symbols).to be_empty
      end
    end

    context "when role assigned" do
      before do
        FactoryGirl.create(:role, user: user, name: "visitor")
      end

      it "includes the role as symbol" do
        expect(user.role_symbols).to include(:visitor)
      end
    end
  end

  describe "#has_role?" do
    context "when applicant role assigned" do
      before do
        FactoryGirl.create(:role, user: user, name: "applicant")
      end

      it "has the applicant role" do
        expect(user.has_role?(:applicant)).to be_true
      end
    end
  end

end
