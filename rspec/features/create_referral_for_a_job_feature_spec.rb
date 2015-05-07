# -*- encoding : utf-8 -*-
require 'spec_helper'

def submit_job_application(listing)
  expect(page).to have_content(listing.title)
  expect(page).to have_content('Bewerben')

  within '.apply' do
    click_link("With form")
  end
  expect(page).to have_content("Application for #{listing.title}")

  within 'form' do
    fill_in "Email", with: "max.mustermann@example.com"
    fill_in "Password", with: "secret123"
    fill_in "Repeat Password", with: "secret123"

    fill_in "First name", with: "Maximilian"
    fill_in "Last Name", with: "Mustermann"
    fill_in "Birthday", with: "15.10.1980"
    fill_in "Message", with: "Ich bin am besten nach 19h zu erreichen"

    click_submit
  end
  expect(page).to have_content("Thank you very much, your application has been submitted")
end

feature "Visitor creates referral for a job", %q(
  As a visitor
  In order to recommend a job
  I want to create a referral to share
) do

  scenario "on his first visit to the site after browsing the overview page as not yet registered user" do
    visit listing_path(listing_one)

    within ".nav.navbar-nav.navbar-right" do
      expect(page).to have_content("Log in")
    end

    expect { submit_job_application(listing_one) }.to change { JobApplication.count }.by(1)

    within ".nav.navbar-nav.navbar-right" do
      expect(page).not_to have_content("Log in")
    end
  end

  scenario "on his first visit to the site after browsing the overview page" do
    visit listing_path(listing_one)

    within ".nav.navbar-nav.navbar-right" do
      expect(page).to have_content("Log in")
    end

    submit_job_application(listing_one)

    job_application = listing_one.job_applications.first

    expect(job_application.referrer).to be_nil
    expect(job_application.user.referrer).to be_nil

  end

  scenario "on his first visit being referred to a job listing" do
    visit listing_path(listing_one, ref: "REFUSR001")

    submit_job_application(listing_one)

    job_application = listing_one.job_applications.first

    expect(job_application.referrer).to eq(referrer_user_one)
    expect(job_application.user.referrer).to eq(referrer_user_one)
  end

  scenario "on a subsequent visit being referred to a job listing before" do
    visit listing_path(listing_one, ref: "REFUSR001")

    visit root_path

    visit listing_path(listing_one)
    submit_job_application(listing_one)

    job_application = listing_one.job_applications.first

    expect(job_application.referrer).to eq(referrer_user_one)
    expect(job_application.user.referrer).to eq(referrer_user_one)
  end

  scenario "on a subsequent visit being referred again after having been referred to a job listing before" do
    visit listing_path(listing_one, ref: "REFUSR001")

    visit root_path

    visit listing_path(listing_one, ref: "REFUSR002")
    submit_job_application(listing_one)

    job_application = listing_one.job_applications.first

    expect(job_application.referrer).to eq(referrer_user_two)
    expect(job_application.user.referrer).to eq(referrer_user_two)
  end

  scenario "that he has not been referred to" do
    visit listing_path(listing_one, ref: "REFUSR001")

    visit root_path

    visit listing_path(listing_two)
    submit_job_application(listing_two)

    job_application = listing_two.job_applications.first

    expect(job_application.referrer).to be_nil
    expect(job_application.user.referrer).to eq(referrer_user_one)
  end

  scenario "that he has been referred to by himself" do
    visit listing_path(listing_one, ref: "REFUSR001")

    submit_job_application(listing_one)

    job_application = listing_one.job_applications.first

    expect(job_application.referrer).to eq(referrer_user_one)
    expect(job_application.user.referrer).to eq(referrer_user_one)

    user_self = job_application.user
    visit listing_path(listing_two, ref: user_self.code)

    expect(page).to have_content("Notice: You cannot recommend yourself, but nice try ;-)")

  end

  scenario "that he has already applied for" do
    visit listing_path(listing_one, ref: "REFUSR001")

    submit_job_application(listing_one)

    expect {submit_job_application(listing_one)}.to_not change{listing_one.job_applications.count}.by(1)

    expect(page).to have_content("Notice: You already applied for this job. If you want to edit your profile, please log in and change the existing application.")
  end



end

__END__