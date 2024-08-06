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

    test "base_mailer sends an email with default sender" do
      email = Shieldify::Mailer.with(@options).base_mailer.deliver_now

      assert_emails 2
      assert_equal ['shieldify@example.com'], email.from
      assert_equal [@options[:user].unconfirmed_email], email.to
      assert_equal 'Email Confirmation Instructions', email.subject
    end

    test "base_mailer sends an email with custom sender" do
      # Modificar la configuración para esta prueba
      Shieldify::Configuration.mailer_sender = 'custom@example.com'

      email = Shieldify::Mailer.with(@options).base_mailer.deliver_now

      assert_emails 2
      assert_equal ['custom@example.com'], email.from
      assert_equal [@options[:user].unconfirmed_email], email.to
      assert_equal 'Email Confirmation Instructions', email.subject
    end

    test "base_mailer sends an email with default reply_to" do
      email = Shieldify::Mailer.with(@options).base_mailer.deliver_now

      assert_emails 2
      assert_equal ['shieldify@example.com'], email.from
      assert_equal [@options[:user].unconfirmed_email], email.to
      assert_equal 'Email Confirmation Instructions', email.subject
      assert_equal ['shieldify@example.com'], email.reply_to
    end

    test "base_mailer sends an email with custom reply_to" do
      # Modificar la configuración para esta prueba
      Shieldify::Configuration.reply_to = 'custom-reply@example.com'

      email = Shieldify::Mailer.with(@options).base_mailer.deliver_now

      assert_emails 2
      assert_equal ['shieldify@example.com'], email.from
      assert_equal [@options[:user].unconfirmed_email], email.to
      assert_equal 'Email Confirmation Instructions', email.subject
      assert_equal ['custom-reply@example.com'], email.reply_to
    end

    teardown do
      # Restaurar los valores predeterminados después de las pruebas
      Shieldify::Configuration.mailer_sender = 'shieldify@example.com'
      Shieldify::Configuration.reply_to = 'shieldify@example.com'
    end
  end
end
