#language: en

# Note: the following features have been rewritten in english as the original project was done in German, so I stripped out many comments and some scenarios. I hope it is still useful for my application.

Feature: Invitation request
	As a visitor of the website
  I'd like to request an invitation
  to get notified when the service will launch
	
	Background:
		Given I am not logged in
		
	Scenario: User visits the website
    When I visit the homepage
		Then I should see a button with the text "Request Invitation"
    
  Scenario: User sees the form to request an invitation
    When I visit the homepage
    And I click the button "Request Invitation"
    Then I should see a form with the field "Email"
    
  Scenario: User signs up to receive an invitation
    When I request an invitation with the valid email "christian@russ.de" anfordere
    Then I should see a message with the text "Thank you for your interest!"
    And the message should be a success-message
    And the email "christian@russ.de" should be stored in the database
    And the account "christian@russ.de" must not be activated
    And the receipient "christian@russ.de" should receive an email with the subject "We received your invitation request"
    
  Scenario: User signs up with an invalid email
    When I request an invitation with an invalid email
    Then I should see a message with the text "Invalid email"
		
		
	Scenario: Waiting user gets activated by an admin
		When someone requested an invitation with the valid email "christian@russ.de"
		And I am logged in as admin
		When I view the invitation request listing
		And I invite the user with the email "christian@russ.de"
    Then the account "christian@russ.de" should not be activated
    And the receipient with the email "christian@russ.de" should receive an invitation email
	
  Scenario: Admin activates a waiting user
			When someone with the email "christian@russ.de" requests an invitation
			And I am logged in as admin
			And I visit the "user_waitlist" page
			And I activate the account with the email "christian@russ.de" freischalte
			Then the account with the email "christian@russ.de" should be active
			And the receipient "christian@russ.de" should receive an email with the subject "Welcome!"
			And the email should contain the text "Activation-link"