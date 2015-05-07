require 'spec_helper'

describe ListingForm do
  let(:attrs) { FactoryGirl.attributes_for(:listing_form) }
  let(:listing) { FactoryGirl.build(:listing) }
  subject(:listing_form) { described_class.new(attrs.merge(listing: listing)) }

  it "has a valid factory" do
    expect(listing_form).to be_valid
  end

  describe "#validates" do
    [
        :title, :experience_years, :description, :industry, :status,  :region,
        :education, :work_type, :salary_amount, :bonus_amount, :start_date_at
    ].each do |attr|
      it "presence of #{attr}" do
        listing_form.send("#{attr}=", nil)
        expect(listing_form).not_to be_valid
      end
    end

    context "start_date" do
      let(:future_date) { 1.month.from_now.beginning_of_month }

      it "as a properly formatted string" do
        listing_form.start_date_at = future_date.strftime("%d.%m.%Y")
        expect(listing_form).to be_valid
      end

# begin  Currently old date is valid, show as "immediately" in view. So no check on old dates

      it "is invalid when bad string" do
        listing_form.start_date_at = "abc"
        expect(listing_form).not_to be_valid
      end
    end

    context "bonus_amount" do

      # initial in factory: 1200
      it "as valid amount > 0" do
        listing_form.bonus_amount = "1300"
        expect(listing_form).to be_valid
      end

      it "is invalid when amount is a string" do
        listing_form.bonus_amount = "abc"
        expect(listing_form).not_to be_valid
      end

      it "is invalid when new amount is < old amount" do
        listing_form.bonus_amount = "1100"
        expect(listing_form).not_to be_valid
      end

      it "is invalid when created with bonus_amount < 1" do
        attrs[:bonus_amount] = listing[:bonus_amount] = 0
        listing_form = described_class.new(attrs.merge(listing: listing))
        expect(listing_form).not_to be_valid
      end

    end

    context "numericality of" do
      it "salary_amount" do
        listing_form.salary_amount = "10c"
        expect(listing_form).not_to be_valid
      end

      it "bonus_amount" do
        listing_form.bonus_amount = "10c"
        expect(listing_form).not_to be_valid
      end

      describe "experience_years" do
        it "and integer" do
          listing_form.experience_years = "10.1"
          expect(listing_form).not_to be_valid
        end
      end
    end

    it "industry to be in valid options" do
      listing_form.industry = "abc123"
      expect(listing_form).not_to be_valid
    end

    it "work_type to be in valid options" do
      listing_form.work_type = "abc123"
      expect(listing_form).not_to be_valid
    end

    it "education to be in valid options" do
      listing_form.education = "abc123"
      expect(listing_form).not_to be_valid
    end
  end

  describe "#persistence" do
    context "new record" do
      let(:listing) { Listing.new }

      context "when valid" do
        it "saves the record when valid" do
          expect(listing_form).to be_valid

          expect {
            listing_form.persist
          }.to change { Listing.count }.by(1)
        end

        [
            :title, :start_date_at, :experience_years, :region, :salary_amount, :bonus_amount,
            :description, :status, :industry, :education, :work_type
        ].each do |attr|
          it "sets attribute #{attr}" do
            listing_form.persist

            expect(listing_form.listing.send("#{attr}".to_sym)).not_to be_nil
          end
        end
      end

      context "when invalid" do
        before do
          listing_form.stub(:valid?) { false }
        end

        it "does not save the record when invalid" do
          expect(listing_form).not_to be_valid
          expect {
            listing_form.persist
          }.not_to change { Listing.count }
        end
      end
    end

    context "existing record" do
      let(:listing) { FactoryGirl.create(:listing, title: "Cogito ergo sum")}

      before do
        listing_form.listing = listing
      end

      it "will be updated when valid" do
        listing_form.title = "New title"
        expect{ listing_form.persist }.to change{
          Listing.find(listing).title
        }.from("Cogito ergo sum").to("New title")
      end

      it "will not be updated when invalid" do
        listing_form.title = "New title"
        listing_form.stub(:valid?) { false }
        expect(listing_form).not_to be_valid

        expect{ listing_form.persist }.not_to change{ Listing.find(listing).title }
      end
    end
  end
end

