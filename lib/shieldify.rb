require "shieldify/version"
require "shieldify/railtie"
require "shieldify/active_record"

module Shieldify
  class Configuration
    include Singleton

    # Email regex used to validate email formats.
    mattr_accessor :email_regexp
    @@email_regexp = /\A[^@\s]+@[^@\s]+\z/

    # Range validation for password length.
    mattr_accessor :password_length
    @@password_length = 6..30

    # Used to send notification to the original user email when their email is changed.
    mattr_accessor :send_email_changed_notification
    @@send_email_changed_notification = true

    # Used to enable sending notification to user when their password is changed.
    mattr_accessor :send_password_change_notification
    @@send_password_change_notification = true

    # Number of authentication tries before locking an account.
    mattr_accessor :maximum_attempts
    @@maximum_attempts = 20

    # The parent controller for the internal controllers.
    mattr_accessor :parent_controller
    @@parent_controller = "ApplicationController"

    # The parent mailer for internal mailers.
    mattr_accessor :parent_mailer
    @@parent_mailer = "ActionMailer::Base"

    # Default mailer sender.
    mattr_accessor :mailer_sender
    @@mailer_sender = "shieldify@example.com"

    # Default mailer sender.
    mattr_accessor :reply_to
    @@reply_to = "shieldify@example.com"
  end

  def self.setup
    yield Configuration.instance
  end
end
