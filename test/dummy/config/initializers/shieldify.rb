Shieldify.setup do |conf|

  ## Reset Email Password
  
  # This configuration defines the URL of the frontend form where users will be redirected to reset their password.
  # When a user requests a password reset, the backend will generate a token and include this URL in the email sent to the user.
  # The URL should point to the password reset form on the frontend application, and it will include the reset token as a query parameter.
  # conf.reset_password_form_url = "http://localhost:3000/reset-password"

  # This configuration defines the URL to redirect users to after they request an email password reset token.
  # The URL will be used for redirection whether the request is successful or fails, with appropriate messages sent in the headers.
  # conf.after_request_reset_password_url = "http://localhost:3000/request-password-recovery"

  # This configuration defines the URL to redirect users to after they attempt to reset their password.
  # The URL will be used for redirection whether the reset is successful or fails, with appropriate messages sent in the headers.
  # conf.after_reset_password_url = "http://localhost:3000/login"

  ## Email Confirmation

  # This configuration defines the URL to redirect users to after they have confirmed their email address.
  # This URL is used for redirection following a successful email confirmation.
  # It can be set to any page in your frontend application where users should land after their email has been confirmed.
  # conf.before_confirmation_url = "http://localhost:3000/login"

  ## Mailer

  # The parent mailer for internal mailers.
  # The default value is "ActionMailer::Base", which sets the base class for all internal mailers.
  # You can change this to another mailer class if your application requires a different base mailer.
  # conf.parent_mailer = "ActionMailer::Base"

  # The default email address used as the sender for outgoing emails.
  # The default value is "shieldify@example.com", and it is necessary to change this to a valid email address for your application.
  # conf.mailer_sender = "shieldify@example.com"

  # The default email address used for the "Reply-To" field in outgoing emails.
  # The default value is "shieldify@example.com", and it is necessary to change this to a valid email address for your application.
  # conf.reply_to = "shieldify@example.com"

  # Used to send notification to the original user email when their email is changed.
  # The default value is true, and it is recommended to keep this enabled for security purposes.
  # conf.send_email_changed_notification = false

  # Used to enable sending notification to user when their password is changed.
  # The default value is true, and it is recommended to keep this enabled for security purposes.
  # conf.send_password_changed_notification = false

  ## Password

  # Password complexity regex.
  # Explanation of the regular expression:
  # - (?=.*\d) ensures there is at least one digit
  # - (?=.*[a-z]) ensures there is at least one lowercase letter
  # - (?=.*[A-Z]) ensures there is at least one uppercase letter
  # - (?=.*[@$#!%*?&]) ensures there is at least one of these special characters
  # - \S{8,} ensures the password is at least 8 characters in length and contains no spaces
  # The default value enforces the above rules, ensuring a strong password policy.
  # It is possible to change this regex to suit your application's specific requirements.
  # conf.password_complexity = /[expression-here]/

  # JWT Related Configuration

  # The secret key used to encode and decode JWT tokens.
  # The default value is "whatever", but it is highly recommended to change this to a strong,
  # unique secret for your application.
  # conf.jwt_secret = Rails.application.credentials.jwt_secret

  # The issuer claim for the JWT tokens.
  # The default value is "Shieldify". You can change this to match your application's name or domain.
  # conf.jwt_issuer = "Shieldify"

  # The expiration time for the JWT tokens in hours.
  # The default value is 24 hours. You can adjust this to set the desired token validity period.
  # conf.jwt_exp = 24.hours.from_now.to_i
end