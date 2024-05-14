require 'test_helper'

module Shieldify
  class MailerTest < ActionMailer::TestCase

    setup do
      user = create(:user)
      @options = {
        user: user,
        email_to: user.unconfirmed_email,
        token: user.email_confirmation_token,
        action: 'email_confirmation_instructions'
      }
    end

    test "base_mailer sends an email with correct headers" do
      email = Shieldify::Mailer.with(@options).base_mailer.deliver_now

      assert_emails 2
      assert_equal ['shieldify@example.com'], email.from
      assert_equal [@options[:user].unconfirmed_email], email.to
      assert_equal 'Email Confirmation Instructions', email.subject
    end
  end
end