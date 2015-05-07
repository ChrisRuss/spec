# -*- encoding : utf-8 -*-
require 'spec_helper'

feature "Regular user cannot access admin section", %q(
  As a regular user
  I want to be denied from accessing the admin section
  In order to trust the system with my data
) do

  include_context "logged in as user"

  background do
    within ".nav.navbar-nav.navbar-right" do
      expect(page).not_to have_content("Admin")
    end
  end

  scenario "and is shown error message for company administration" do
    visit admin_companies_path
    expect(page).to have_content("You are not allowed to access this action.")
  end

  scenario "and is shown error message for company administration" do
    visit admin_company_listings_path(:company_id)
    expect(page).to have_content("You are not allowed to access this action.")
  end
end
