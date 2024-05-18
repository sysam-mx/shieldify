require "shieldify/version"
require "shieldify/railtie"

module Shieldify
  class Configuration
    include Singleton

    # Default mailer sender.
    mattr_accessor :mailer_sender
    @@mailer_sender = "shieldify@example.com"

    # Default mailer sender.
    mattr_accessor :reply_to
    @@reply_to = "shieldify@example.com"

    # Email regex used to validate email formats.
    mattr_accessor :email_regexp
    @@email_regexp = URI::MailTo::EMAIL_REGEXP

    # Password complexity regex
    # Explanation of the regular expression:
    # - (?=.*\d) ensures there is at least one digit
    # - (?=.*[a-z]) ensures there is at least one lowercase letter
    # - (?=.*[A-Z]) ensures there is at least one uppercase letter
    # - (?=.*[@$#!%*?&]) ensures there is at least one of these special characters
    # - \S{8,} ensures the password is at least 8 characters in length and contains no spaces
    mattr_accessor :password_complexity
    @@password_complexity = /\A(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@$#!%*?&])\S{6,}\z/

    # Used to send notification to the original user email when their email is changed.
    mattr_accessor :send_email_changed_notification
    @@send_email_changed_notification = true

    # Used to enable sending notification to user when their password is changed.
    mattr_accessor :send_password_changed_notification
    @@send_password_changed_notification = true

    # Number of authentication tries before locking an account.
    mattr_accessor :maximum_attempts
    @@maximum_attempts = 20

    # The parent controller for the internal controllers.
    # mattr_accessor :parent_controller
    # @@parent_controller = "ApplicationController"

    # The parent mailer for internal mailers.
    mattr_accessor :parent_mailer
    @@parent_mailer = "ActionMailer::Base"

    # JWT related
    mattr_accessor :jwt_secret
    @@jwt_secret = "whatever"

    mattr_accessor :jwt_issuer
    @@jwt_issuer = "Shieldify"

    mattr_accessor :jwt_exp
    @@jwt_exp = 24
  end

  def self.setup
    yield Configuration.instance
  end
end

require "shieldify/models/email_authenticatable"
require "shieldify/models/email_authenticatable/registerable"
require "shieldify/models/email_authenticatable/confirmable"
require "shieldify/mailer"
