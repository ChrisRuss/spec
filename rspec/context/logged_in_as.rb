shared_context "logged in as user" do

  let!(:user)  {FactoryGirl.create(:user, email: "max.mustermann@example.com", password: "blabla123")}

  before do
    visit "/"
    account_login("max.mustermann@example.com", "blabla123")
  end

end

shared_context "logged in as admin" do
  let!(:user) {FactoryGirl.create(:user, :admin, roles: %w(admin), email: "admin@example.com", password: "blabla123")}

  before do
    visit "/"
    admin_login("admin@example.com", "secret123")
  end
end

shared_context "logged in as company_admin" do
  let!(:user) {FactoryGirl.create(:user, :admin, roles: %w(company_admin), email: "company_admin@example.com", password: "blabla123")}

  before do
    visit "/"
    admin_login("company_admin@example.com", "blabla123")
  end
end

shared_context "logged in as listing_admin" do
  let!(:user) {FactoryGirl.create(:user, :admin, roles: %w(company_admin listing_admin), email: "listing_admin@example.com", password: "blabla123")}

  before do
    visit "/"
    admin_login("listing_admin@example.com", "blabla123")
  end
end