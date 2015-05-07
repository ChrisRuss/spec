# -*- encoding : utf-8 -*-
require 'spec_helper'

feature "User sends an invitation", %q(
  As a regular user who is logged in
  I want to be able to invite others to use this service
  In order to gain some "networker"-credits
) do

  include_context "logged in as user"

  background do
    within ".nav.navbar-nav.navbar-right" do
      expect(page).to have_content("Invite friends")
    end
  end

  scenario "sucessfully send" do
    visit '/'

    click_link "Invite friends"

    expect(page).to have_content("Email addresses of your friends")

    within "form" do
      fill_in 'Emails', with: "test@example.com, test1@example.com, test2@example.com, test3@example.com"
      fill_in 'Message', with:"testmail!"
      click_submit
    end

    expect(page).to have_content('Thank you!')
    expect(page).to have_content('Your invitation has been sent')
  end




end