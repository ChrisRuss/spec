#!/bin/env ruby
# encoding: utf-8
#language: de

### Einige UTILITY METHODS sind schon in den generellen user_steps.rb vorhanden ###

### weitere Utility Methods ###
def delete_wannabe user
  @user_delete = User.first conditions: {:email => user.email}
  @user_delete.destroy unless @user_delete.nil?
end

def find_wannabe user
  @user = User.first conditions: {:email => user.email}
end

def invitation_request user
  # delete_wannabe user
  visit '/users/sign_up'
  fill_in t("simple_form.labels.defaults.email"), :with => user.email
  click_button t("accountmenu.pre_register")
  find_wannabe user
  # @user.save!
end

### Angenommen ###

# Angenommen, dass als erlaubte formulierung
# Angenommen /^, dass (.+)$/ do |step|
#   step
# end

Angenommen /^sei, dass (.+)$/ do |tostep|
  step "#{tostep}"
end


### GIVEN ###
Angenommen /^ich nicht (?:eingeloggt|angemeldet) bin$/ do
  visit '/users/sign_out'
end

Angenommen /^ich (?:ausgeloggt|abgemeldet) bin$/ do
  visit '/users/sign_out'
end

Angenommen /^ich (?:eingeloggt|angemeldet) bin$/ do
  create_user
  # durch create_user wird @user gesetzt
  confirm_user(@user.email)
  invited_user(@user.email)
  sign_in(@user.email)
end

Angenommen /^ich mit der E-Mail(?:-Adresse|) "([^\"]*?)" als gültiger Nutzer eingeloggt bin$/ do |arg1|
  create_user arg1
  confirm_user arg1
  invited_user arg1
  sign_in arg1
end

Angenommen /^ich als Nutzer existiere$/ do
  create_user
end

Angenommen /^ich nicht als Nutzer existiere$/ do
  create_visitor
  delete_user
end

Angenommen /^ich als unbestätigter Nutzer existiere$/ do
  create_unconfirmed_user
end

Angenommen /^ich (admin|user|VIP|recruiter|premiumrec) Rechte besitze$/ do |rights|
  if rights=="VIP"
    @user.make_vip!
  else
    give_rights(rights, @user)
  end
end

Angenommen(/^ich als Admin eingeloggt bin$/) do
  user = FactoryGirl.build(:user)
  user.assign_attributes(:email => "kontakt@foogoo.info")
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

Angenommen /^ich bin ein bestätigter (?:user|User|Nutzer)$/ do
  confirm_user 
end

Angenommen /^ich bin ein eingeladener (?:user|User|Nutzer)$/ do
  invited_user 
end

### WHEN ###
Wenn /^ich mich mit gültigen Anmeldedaten (?:einlogge|anmelde)$/ do
  create_visitor
  sign_in
end

Wenn /^ich mich auslogge$/ do
  visit '/users/sign_out'
end

Wenn /^Ich mich mit gültigen Nutzerdaten registriere$/ do
  create_visitor
  sign_up
end

Wenn /^ich mich mit einer ungültigen E-Mail(?:-Adresse|) registriere$/ do
  create_visitor
  @visitor = @visitor.assign_attributes(:email => "notanemail")
  sign_up
end

Wenn /^ich mich ohne Passwort-Wiederholung registriere$/ do
  create_visitor
  @visitor = @visitor.assign_attributes(:password_confirmation => "")
  sign_up
end

Wenn /^ich mich ohne Passwort registriere$/ do
  create_visitor
  @visitor = @visitor.assign_attributes(:password => "")
  sign_up
end

Wenn /^ich mich mit falscher Passwort-Wiederholung registriere$/ do
  create_visitor
  @visitor = @visitor.assign_attributes(:password_confirmation => "please123")
  sign_up
end

Wenn /^ich auf die Seite zurückkehre$/ do
  visit '/'
end

Wenn /^ich (.+) besuche$/ do |page|
  visit path_to(page)
end

Wenn /^ich mich mit einer falschen E-Mail(?:-Adresse|) (?:einlogge|anmelde)$/ do
  @visitor = @user.clone
  @visitor = @visitor.assign_attributes(:email => "wrong@example.com")
  sign_in
end

Wenn /^ich mich mit einem falschen Passwort (?:einlogge|anmelde)$/ do
  @visitor = @user.clone
  @visitor = @visitor.assign_attributes(:password => "wrongpass")
  sign_in
end

Wenn /^ich mich mit (?:dem Benutzer|den Benutzerdaten) "([^\"]*?)" (?:und dem Passwort|,) "([^\"]*?)" anmelde$/ do |user, pword|
  visit '/users/sign_in'
  fill_in t("simple_form.labels.defaults.email"), :with => user
  fill_in t("simple_form.labels.defaults.password"), :with => pword
  click_button t("accountmenu.sign_in")
end

Wenn /^ich meine Account-Info(?:rmation|) (?:bearbeite|editiere)$/ do
  click_link t("accountmenu.edit_account")
  fill_in t("simple_form.labels.defaults.name"), :with => "newname"
  fill_in "user_password", :with => @visitor.password
  fill_in t("simple_form.labels.defaults.password_confirmation"), :with => @visitor.password
  fill_in t("simple_form.labels.defaults.current_password"), :with => @visitor.password
  click_button t("devise_extend.registration.update")
end

Wenn /^ich die Auflistung der Nutzer (?:anschaue|besuche|betrachte)$/ do
  visit '/admin/users/'
end

Wenn /^ich eine Einladung mit einer gültigen E-Mail(?:-Adresse|) "([^\"]*?)" anfordere$/ do |arg1|
  user = FactoryGirl.build(:user)
  user.assign_attributes(:email => arg1)
  invitation_request user
end

Wenn /^ich erneut (in(?:nerhalb|)|nach) (\d+)(?:h|Stunde(?:n|)) eine Einladung mit einer gültigen E\-Mail(?:-Adresse|) "([^\"]*?)" anfordere$/ do |arg1, arg2, arg3|
  arg2=arg2.to_i
  theuser = User.find_by_email(arg3)
  theuser.should_not be_nil
  case arg1
  when "nach"
    theuser.updated_at = (arg2.hours + 1.minutes).ago
  when "in"
    theuser.updated_at = (arg2.hours + 1.minutes).ago
  else
    theuser.updated_at = (arg2.hours - 1.minutes).ago
  end
  
  theuser.invitation_sent_at = theuser.updated_at if theuser.invitation_sent_at
  theuser.save!
    
  theuser2 = FactoryGirl.build(:user)
  theuser2.assign_attributes(:email => arg3)
  invitation_request theuser2
end

Wenn /^ich eine Einladung mit einer ungültigen E-Mail(?:-Adresse|) anfordere$/ do
  user = FactoryGirl.build(:user)
  user.assign_attributes(:email => "notanemail")
  invitation_request user
end

Wenn /^ich (?:einen|den) Button(?:\smit|) "([^\"]*?)" (?:anklicke|anwähle)$/ do |arg1|
  click_button(arg1)
end

Wenn /^ich einen Passwort-Reset für (?:die E-Mail(?:-Adresse|) |)"([^\"]*?)" mache$/ do |arg1|
  visit new_user_password_path
  fill_in "user_email", :with => arg1
  find("input[type='submit']").click
end

# Alias für semantische Nutzung:
Wenn /^ich die E-Mail(?:-Adresse|) "([^\"]*?)" mittels Passwort\-Reset bestätige$/ do |arg1|
  step "ich einen Passwort-Reset für \"#{arg1}\" mache"
  step "der Empfänger \"#{arg1}\" die E-Mail mit dem Betreff \"Anleitung um Dein Passwort zurückzusetzten\" öffnet"
  step "ich den ersten Link in der E-Mail anklicken"
	step "ich das Feld \"user_password\" mit \"test123\" ausfülle"
	step "ich das Feld \"user_password_confirmation\" mit \"test123\" ausfülle"
	step "ich den Button mit \"Passwort ändern!\" anklicke"
end

Wenn /^ich das Feld "(\S+)" mit "(\S+)" ausfülle$/ do |fieldname, inputtext|
  fill_in fieldname, :with => inputtext
end

Wenn /^ich (?:den Button |)"([^\"]*)" innerhalb (?:von |)"([^\"]*)" (?:drücke|klicke|clicke|bestätige|betätige)$/ do |clickable,scope_selector|
  within(scope_selector) do      
    click_on(clickable)
  end
end

Wenn /^ich den Zugang mit der E-Mail(?:-Adresse|) "([^\"]*?)" über das Admin\-Interface einlade$/ do |arg1|
  step "ich die Auflistung der Nutzer anschaue"
  user = User.find_by_email(arg1)
  user.should_not be_nil
  step "ich \"Einladen!\" innerhalb \"tr#user_#{user.id}\" klicke"
end

# Invite-Automatisierung als VIP:
Wenn /^ich als VIP-User (?:mit der E-Mail(?:-Adresse|) "([^\"]*?)" |)die E-Mail(?:-Adresse|) "([^\"]*?)" über das Invitation-Formular einlade$/ do |arg0, arg1|
  step "ich ausgeloggt bin"
  if arg0.blank? 
    step "ich eingeloggt bin"
  else
    step "ich mit der E-Mail \"#{arg0}\" als gültiger Nutzer eingeloggt bin"
  end
  step "ich VIP Rechte besitze"
  step "ich die Invitation Seite besuche"
  step "sollte ich Text mit \"Schicke eine Einladung\" sehen"
  step "ich das Feld \"user_email\" mit \"#{arg1}\" ausfülle"
  step "ich den Button mit \"Einladen!\" anklicke"
  step "sollte ich eine Nachricht mit \"#{t(:send_instructions, :scope => [:devise, :invitations], :email => arg1)}\" sehen"
  step "die E-Mail-Adresse \"#{arg1}\" sollte in der Datenbank gespeichert sein"
end

Wenn /^ich als VIP-User (?:mit der E-Mail(?:-Adresse|) "([^\"]*?)" |)erneut (in(?:nerhalb|)|nach) (\d+)(?:h|Stunde(?:n|)) die E\-Mail(?:-Adresse|) "([^\"]*?)" über das Invitation-Formular einlade$/ do |arg0, arg1, arg2, arg3|
  arg2=arg2.to_i
  theuser = User.find_by_email(arg3)
  theuser.should_not be_nil
  case arg1
  when "nach"
    theuser.updated_at = (arg2.hours + 1.minutes).ago
  when "in"
    theuser.updated_at = (arg2.hours + 1.minutes).ago
  else
    theuser.updated_at = (arg2.hours - 1.minutes).ago
  end
  
  theuser.invitation_sent_at = theuser.updated_at if theuser.invitation_sent_at
  theuser.save!
  
  if arg0.blank?
    step "ich als VIP-User die E-Mail \"#{arg3}\" über das Invitation-Formular einlade"
  else
    step "ich als VIP-User mit der E-Mail \"#{arg0}\" die E-Mail \"#{arg3}\" über das Invitation-Formular einlade"
  end
  
end

# Theoretisch könnte man eine generische Methode schreiben, die anstelle des VIP-Users einen Parameter entgegennimmt und daraus eine Instanzvariable bastelt
# Im Dann-Schritt könnte man diese dann ebenso abrufen...
# Fürs erste genügt aber folgendes
Wenn /^ich den VIP-User cached habe?$/ do
  print "Wenn die Cached-VIP Methode genutzt wird: Achtung, VIP kann sich im Laufe der Plattform-Entwicklung evtl ändern. Bitte Korrektheit prüfen!"
  @cached_user = @visitor
end

Wenn /^der Empfänger (?:mit der E-Mail(?:-Adresse|) |)"([^\"]*?)" seinem Einladungslink folgt$/ do |arg1|
  user = User.find_by_email(arg1)
  user.should_not be_nil
  user.invitation_sent_at.should_not be_nil
  user.invitation_token.should_not be_nil
  invite_link = Rails.application.routes.url_helpers.accept_user_invitation_url(:invitation_token => user.invitation_token, :host => ActionMailer::Base.default_url_options[:host], :invitermail => user.invited_by.email).gsub("&", "&amp;")
  step "ich \"#{invite_link}\" in der E-Mail folge"
  #debugging:
  # save_and_open_page
end

Wenn /^ich für (?:den Empfänger mit der E-Mail(?:-Adresse|) |die E-Mail(?:-Adresse|) |)"([^\"]*?)" einen unvollständigen Passwort-Reset ausführe$/ do |arg1|
  visit new_user_password_path
  fill_in "user_email", :with => arg1
  find("input[type='submit']").click
end


Wenn /^ich ein neues Passwort eingebe$/ do
	step "ich das Feld \"user_password\" mit \"test123\" ausfülle"
	step "ich das Feld \"user_password_confirmation\" mit \"test123\" ausfülle"
	step "ich den Button mit \"Passwort ändern!\" anklicke"
end

Wenn /^ich ein neues Passwort vergebe$/ do
  step "ich ein neues Passwort eingebe"
	step "ich sollte eine Nachricht mit \"Dein Passwort wurde geändert.\" sehen"
end

Wenn /^(?:der Empfänger(?: mit der E-Mail(?:-Adresse|)|) |die E-Mail(?:-Adresse|) |)"([^\"]*?)" seine Einladung bestätigt$/ do |arg1|
  step "sollte der Empfänger \"#{arg1}\" eine E-Mail mit dem Betreff \"Du wurdest eingeladen!\" empfangen"
  step "der Empfänger \"#{arg1}\" die E-Mail mit dem Betreff \"Du wurdest eingeladen!\" öffnet"
  step "der Empfänger \"#{arg1}\" seinem Einladungslink folgt"
  step "sollte ich auf die accept_user_invitation Seite weitergeleitet werden"
  step "ich ein neues Passwort eingebe"
  step "ich sollte eine Nachricht mit \"Dein Passwort wurde erfolgreich gespeichert.\" sehen"
end

Wenn /^ich den Zugang (?:mit der E-Mail(?:-Adresse|) |)"([^\"]*?)" freischalte$/ do |arg1|
  step "ich die Auflistung der Nutzer anschaue"
  user = User.find_by_email(arg1)
  user.should_not be_nil
  step "ich \"Aktivieren!\" innerhalb \"tr#user_#{user.id}\" klicke"
end
  

### THEN ###

## Durch erlaubte "Und"-Klauseln, muss ein umstellen von sollte XXX und XXX sollte möglich sein... ##
Und /^(?!sollte)(.+) sollte (.+)$/ do |who, tostep|
  step %{sollte #{who} #{tostep}}
end

Dann /^sollte ich (?:einloggt|angemeldet) sein$/ do
  page.should have_content t("accountmenu.logout")
  page.should_not have_content t("accountmenu.sign_up")
  page.should_not have_content t("accountmenu.sign_in")
end

Dann /^sollte ich (?:ausgeloggt|abgemeldet)$/ do
  page.should_not have_content t("accountmenu.logout")
  page.should have_content t("accountmenu.sign_up")
  page.should have_content t("accountmenu.sign_in")
end

Dann /^sollte ich eine (?:Nachricht|Meldung) über (?:einen unbestätigten Account|ein unbestätigtes Konto) sehen$/ do
  page.should have_content t("devise.failure.unconfirmed")
end

Dann /^sollte ich eine (?:Nachricht|Meldung) über einen erfolgreichen Login(?:-Versuch|versuch|) sehen$/ do
  page.should have_content t("devise.sessions.signed_in")
end

Dann /^sollte ich eine (?:Nachricht|Meldung) über eine erfolgreiche (?:Anmeldung|Registrierung) sehen$/ do
  page.should have_content t("devise.registrations.signed_up")
end

Dann /^sollte ich eine (?:Nachricht|Meldung) über eine fehlerhafte E-Mail(?:-Adresse|) sehen$/ do
  page.should have_content (t("simple_form.labels.defaults.email") + t("errors.messages.invalid"))
end

Dann /^sollte ich eine (?:Nachricht|Meldung) über ein fehlendes Passwort sehen$/ do
  page.should have_content (t("simple_form.labels.defaults.password") + t("errors.messages.empty"))
end

Dann /^sollte ich eine (?:Nachricht|Meldung) über eine fehlende Passwort-Bestätigung sehen$/ do
  page.should have_content t("errors.messages.confirmation")
end

Dann /^sollte ich eine (?:Nachricht|Meldung) über eine fehlerhafte Passwort-Bestätigung sehen$/ do
  page.should have_content t("errors.messages.confirmation")
end

Dann /^sollte ich eine (?:Nachricht|Meldung) über (?:eine erfolgreiche Abmeldung|einen erfolgreichen Logout) sehen$/ do
  page.should have_content t("devise.sessions.signed_out")
end

Dann /^sollte ich eine (?:Nachricht|Meldung) über eine ungültige Anmeldung sehen$/ do
  page.should have_content t("devise.failure.invalid")
end

Dann /^sollte ich eine (?:Nachricht|Meldung) über (?:ein (?:bearbeitetes|editiertes) Konto|einen (?:bearbeiteten|editierten) Account) sehen$/ do
  page.should have_content t("devise.registrations.updated")
end

Dann /^sollte ich meinen Namen sehen$/ do
  create_user
  page.should have_content @user[:name]
end

Dann /^sollte ich nicht als Nutzer gefunden werden$/ do
  (User.first conditions: {:email => @visitor.email}).should == nil
end

Dann /^sollte ich einen Button(?:\smit|) "([^\"]*?)" sehen$/ do |arg1|
  page.should have_button(arg1)
end

Dann /^sollte ich (?:eine |einen |)(?:Nachricht|Meldung|Text) mit "([^\"]*?)" sehen$/ do |text|
  page.should have_content(text)
end

Dann /^sollte die (?:Nachricht|Meldung) eine (Erfolgs|Fehler)?(?:-Nachricht|-Meldung|nachricht|meldung) sein$/ do |switchcase|
  searchtext = ""
  case switchcase
  when "Erfolgs"
    page.has_css?('div.alert-success')
  when "Fehler"
    page.has_css?('div.alert-error')
  end
end

Dann /^sollte ich ein Formular mit (?:einem|dem) Feld "([^\"]*?)" sehen$/ do |arg1|
  page.should have_content (arg1)
end

Dann /^sollte die E-Mail(?:-Adresse|) "([^\"]*?)" in der Datenbank (?:gefunden werden|gespeichert sein)$/ do |arg1|
  test_user = User.find_by_email(arg1)
  test_user.should respond_to(:email)
end

Dann /^sollte der (?:Account|Zugang) mit der E-Mail(?:-Adresse|) "([^\"]*?)" unbestätigt sein$/ do |arg1|
  test_user = User.find_by_email(arg1)
  test_user.confirmed_at.should be_nil
end

Dann /^sollte der (?:Account|Zugang) mit der E-Mail(?:-Adresse|) "([^\"]*?)" bestätigt sein$/ do |arg1|
  test_user = User.find_by_email(arg1)
  test_user.confirmed_at.should_not be_nil
end

Dann /^sollte ich "([^\"]*?)" in einer Auflistung sehen$/ do |tofind|
  page.should have_content(tofind)
end

Dann /^sollte der Nutzer mit der E-Mail(?:-Adresse|) "([^\"]*?)" als inaktiv angezeigt werden$/ do |arg1|
  # user_elem = find("td.email", :text => arg1).parent
  # within user_elem do |elem|
  #   elem.should have_content("inaktiv")
  # end
  ((find("td.email", :text => arg1)).parent).should have_content(/[Ii]naktiv/)
end

Dann /^sollte der Zugang mit der E-Mail(?:-Adresse|) "([^\"]*?)" und (?:dem |)Passwort "([^\"]*?)" sich nicht anmelden können$/ do |arg1, arg2|
  step 'ich ausgeloggt bin'
	step 'ich mich mit dem Benutzer "#{arg1}" und dem Passwort "#{arg2}" anmelde'
  (page.should have_content(/Dein Account ist nicht aktiv.|Ungültige Anmeldedaten./))
end

Dann /^sollte der (?:Account|Zugang) mit der E-Mail(?:-Adresse|) "([^\"]*?)" (inaktiv|aktiv) sein$/ do |arg1, arg2|
  user = User.find_by_email(arg1)
  user.should_not be_nil
  case arg2
    when "aktiv"
      (user.active_for_authentication?).should be_true
    when "inaktiv"
      (user.active_for_authentication?).should_not be_true
  end
end

Dann /^sollte die E-Mail einen Link zur Bestätigung der Einladung beinhalten$/ do
  user = User.find_by_email(current_email_address)
  user.should_not be_nil
  user.invitation_sent_at.should_not be_nil
  user.invitation_token.should_not be_nil
  invite_link = Rails.application.routes.url_helpers.accept_user_invitation_url(:invitation_token => user.invitation_token, :host => ActionMailer::Base.default_url_options[:host])
  invite_link.should have_content(user.invitation_token)
  step "sollte ich \"#{invite_link}\" im E-Mail-Text sehen"
end

Dann /^sollte der Empfänger (?:mit der E-Mail(?:-Adresse|) |)"([^\"]*?)" (eine|keine|\d+) Einladungsmails? erhalten$/ do |arg1, arg2|
  case arg2
  when "eine"
    step "der Empfänger \"#{arg1}\" sollte eine E-Mail mit dem Betreff \"Du wurdest eingeladen!\" empfangen"
    step "der Empfänger \"#{arg1}\" die E-Mail mit dem Betreff \"Du wurdest eingeladen!\" öffnet"
    step "sollte die E-Mail einen Link zur Bestätigung der Einladung beinhalten"
  when "keine"
    step "der Empfänger \"#{arg1}\" sollte keine E-Mail mit dem Betreff \"Du wurdest eingeladen!\" empfangen"  
  else
    step "der Empfänger \"#{arg1}\" sollte #{arg2.to_i} E-Mail mit dem Betreff \"Du wurdest eingeladen!\" empfangen"
  end
end

Dann /^sollte der cached User der Einlader von dem Empfänger (?:mit der E-Mail(?:-Adresse|) |)"([^\"]*?)" sein$/ do |arg1|
  # Zwar haben wir den User gecached, aber in-Memory Änderungen evtl nicht sichtbar. Lade neu.
  user = User.find_by_email(arg1)
  user.should_not be_nil
  (user.invited_by.email == @cached_user.email).should be_true
end

Dann /^sollte der User mit der E-Mail(?:-Adresse|) "([^\"]*?)" der Einlader von dem Empfänger (?:mit der E-Mail(?:-Adresse|) |)"([^\"]*?)" sein$/ do |arg0, arg1|
  # Zwar haben wir den User gecached, aber in-Memory Änderungen evtl nicht sichtbar. Lade neu.
  inviter = User.find_by_email(arg0)
  user = User.find_by_email(arg1)
  user.should_not be_nil
  (user.invited_by.email == inviter.email).should be_true
end

Dann /^sollte ich die E-Mail(?:-Adresse|) des cached User als (.+) Parameter in der geöffneten E\-Mail sehen$/ do |arg1|
  escapedstring = {("#{arg1}").parameterize.underscore.to_sym => @cached_user.email}.to_query
  step "sollte ich \"#{escapedstring}\" im Text-Teil der E-Mail sehen"
end

Dann /^sollte ich auf die (.+) Seite weitergeleitet (?:werden|worden sein)$/ do |arg1|
  uri = URI.parse(current_url)
  arg1.gsub(" ", "_")
  "#{uri.path}".should == (send("#{arg1}_path"))
end