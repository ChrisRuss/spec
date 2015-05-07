### UTILITY METHODS ###

# Note: Like the features, the some "Given, When and Then" parts are translated from German to English, and I left out several parts, and hope it still works as spec example.

def create_visitor
  @visitor = FactoryGirl.build(:user)
end


#Attention: rewritten method.
# Integrated caching was too confusing. See #delete_user
def find_user(given_mail=@visitor.email)
  @user = User.first conditions: {:email => given_mail}
end

def create_unconfirmed_user(given_mail=@visitor.email)
  create_visitor
  delete_user(given_mail)
  sign_up(given_mail)
  visit '/users/sign_out'
end

def create_user(given_mail=nil)
  create_visitor
  given_mail = @visitor.email if given_mail.blank?
  @visitor.assign_attributes(email: given_mail)
  delete_user(given_mail)
  sign_up(given_mail)
  # sign up sets @user
  @user.password = @visitor.password
  @user.save!
end

def invited_user(given_mail=@visitor.email)
  find_user(given_mail)
  create_visitor
  @user.invitation_accepted_at = Time.now - 1.day
  @user.save!
end

def confirm_user(given_mail=@visitor.email)
  find_user(given_mail)
  create_visitor
  @user.confirmed_at = Time.now - 1.day
  @user.save!
end

def give_rights(rights, to_user=@user)
  to_user.add_role rights.to_sym
  to_user.save!
end

#Attention: original method was
#   @user ||= User.first conditions: {:email => @visitor.email}
# that makes the find method quite confusing
# by using || the new user only gets set when @user-variable nil
# and with changing users we would always have to set him to nil first
# Better no caching here...
def delete_user(given_mail=@visitor.email)
  @user = User.first conditions: {:email => given_mail}
  @user.destroy unless @user.nil?
end

def sign_up(given_mail=@visitor.email)
  delete_user(given_mail)
  visit '/users/sign_up'

  fill_in t("simple_form.labels.defaults.email"), :with => given_mail
  click_button t("accountmenu.pre_register")
  find_user(given_mail)
end

def sign_in(given_mail=@visitor.email, pass=@visitor.password)
  visit '/users/sign_in'
  fill_in t("simple_form.labels.defaults.email"), :with => given_mail
  fill_in t("simple_form.labels.defaults.password"), :with => pass
  click_button t("accountmenu.sign_in")
end

### GIVEN ###
Given /^(?:that |)I am not logged in$/ do
  visit '/users/sign_out'
end

Given /^I am logged in$/ do
  create_user
  confirm_user(@user.email)
  invited_user(@user.email)
  sign_in(@user.email)
end

Given /^I exist as a user$/ do
  create_user
end

Given /^I do not exist as a user$/ do
  create_visitor
  delete_user
end

Given /^I exist as an unconfirmed user$/ do
  create_unconfirmed_user
end

Given /^I have (admin|user|visitor|paid_user|premium|recruiter) rights$/ do |rights|
  if rights=="VIP"
    @user.make_vip!
  else
    give_rights(rights, @user)
  end
end

Given /^I am a confirmed user$/ do
  confirm_user # express the regexp above with the code you wish you had
end

Given /^I am an invited user$/ do
  invited_user # express the regexp above with the code you wish you had
end

Given /^I am logged in as admin$/ do
  user = FactoryGirl.build(:user)
  user.assign_attributes(:email => "christian@russ.de")
  find_wannabe user
  step "I exist as a user"
  step "I am not logged in"
  confirm_user
  invited_user
  @user.add_role :admin
  @user.save!
  step "I sign in with valid credentials"
  step "I see a successful sign in message"
end


### WHEN ###
When /^I sign in with valid credentials$/ do
  create_visitor
  sign_in
end

When /^I sign out$/ do
  visit '/users/sign_out'
end

When /^I sign up with valid user data$/ do
  create_visitor
  sign_up
end

When /^I request an invitation with an invalid email$/ do
  create_visitor
  @visitor = @visitor.assign_attributes(:email => "notanemail")
  sign_up
end

When /^I sign up without a password confirmation$/ do
  create_visitor
  @visitor = @visitor.assign_attributes(:password_confirmation => "")
  sign_up
end

When /^I sign up without a password$/ do
  create_visitor
  @visitor = @visitor.assign_attributes(:password => "")
  sign_up
end

When /^I sign up with a mismatched password confirmation$/ do
  create_visitor
  @visitor = @visitor.assign_attributes(:password_confirmation => "please123")
  sign_up
end

When /^I return to the site$/ do
  visit '/'
end

Wenn /^I visit (.+)$/ do |page|
  visit path_to(page)
end

When /^I sign in with a wrong email$/ do
  @visitor = @user.clone
  @visitor.assign_attributes(:email => "wrong@example.com")
  sign_in
end

When /^I sign in with a wrong password$/ do
  @visitor = @user.clone
  @visitor.assign_attributes(:password => "wrongpass")
  sign_in
end

When /^I edit my account details$/ do
  click_link t("accountmenu.edit_account")
  fill_in t("simple_form.labels.defaults.name"), :with => "newname"
  fill_in "user_password", :with => @visitor.password
  fill_in t("simple_form.labels.defaults.password_confirmation"), :with => @visitor.password
  fill_in t("simple_form.labels.defaults.current_password"), :with => @visitor.password
  click_button t("devise_extend.registration.update")
end

When /^I look at the list of users$/ do
  visit '/users'
end

### THEN ###
Then /^I should be signed in$/ do
  page.should have_content t("accountmenu.logout")
  page.should_not have_content t("accountmenu.sign_up")
  page.should_not have_content t("accountmenu.sign_in")
end

Then /^I should be signed out$/ do
  page.should_not have_content t("accountmenu.logout")
  page.should have_content t("accountmenu.sign_up")
  page.should have_content t("accountmenu.sign_in")
end

Then /^I see an unconfirmed account message$/ do
  page.should have_content t("devise.failure.unconfirmed")
end

Then /^I see a successful sign in message$/ do
  page.should have_content t("devise.sessions.signed_in")
end

Then /^I should see a successful sign up message$/ do
  page.should have_content t("devise.registrations.signed_up")
end

Then /^I should see an invalid email message$/ do
  page.should have_content (t("simple_form.labels.defaults.email") + t("errors.messages.invalid"))
end

Then /^I should see a missing password message$/ do
  page.should have_content (t("simple_form.labels.defaults.password") + t("errors.messages.empty"))
end

Then /^I should see a missing password confirmation message$/ do
  page.should have_content t("errors.messages.confirmation")
end

Then /^I should see a mismatched password message$/ do
  page.should have_content t("errors.messages.confirmation")
end

Then /^I should see a signed out message$/ do
  page.should have_content t("devise.sessions.signed_out")
end

Then /^I see an invalid login message$/ do
  page.should have_content t("devise.failure.invalid")
end

Then /^I should see an account edited message$/ do
  page.should have_content t("devise.registrations.updated")
end

Then /^I should see my name$/ do
  create_user
  page.should have_content @user[:name]
end

Then /^I should not be found as a user$/ do
  (User.first conditions: {:email => @visitor.email}).should == nil
end
