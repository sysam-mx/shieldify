
## [v0.1.0-alpha] - 2024-06-04

### Description

This is the initial alpha release of Shieldify, a Ruby on Rails user authentication plugin. This version includes core features for handling authentication using email/password and JSON Web Tokens (JWT), along with several helper methods for managing user sessions within controllers.

### Added

- **Authentication using Email and Password**:
  - Implemented middleware and Warden strategies to handle authentication requests.
  - Middleware intercepts requests ending with `/shfy/login` to authenticate users via email and password.
  - Warden strategy validates user credentials and generates JWT, sent in the response headers.
  - Customizable response in the controller using `render json: { message: 'Authenticated successfully', user: current_user }`.

- **Authentication using JSON Web Tokens (JWT)**:
  - Implemented middleware and Warden strategies to handle authentication requests containing JWT in the `Authorization` header.
  - Middleware intercepts requests to handle authentication based on the presence of the `Authorization` header.
  - Warden strategy extracts, validates, and authenticates the user if the token is valid.
  - Added support for protecting specific actions in controllers using `before_action :authenticate_user!`.

- **Controller Helpers**:
  - Added `current_user` method to return the currently authenticated user.
  - Added `user_signed_in?` method to check if a user is currently signed in.
  - Added `authenticate_user!` method to ensure a user is authenticated before accessing certain actions.
  - Helpers included by default in `ActionController::API`.

- **Email Authentication Model**:
  - Added `Shieldify::Models::EmailAuthenticatable` module.
  - Provides `has_secure_password` integration for secure password handling.
  - Added `authenticate_by_email` class method to authenticate users by email and password.

  **Capabilities**:
  - `has_secure_password` for secure password management.
  - `authenticate_by_email(email:, password:)` to authenticate users by email and password.

- **Email Confirmation Model**:
  - Added `Shieldify::Models::EmailAuthenticatable::Confirmable` module.
  - Provides email confirmation functionality using tokens.
  - Automatically sends confirmation instructions and manages email confirmations.
  - Supports email change process with pending confirmation.
  - Provides methods to check token expiration and email confirmation status.

  **Capabilities**:
  - `confirm_email` to confirm user's email.
  - `regenerate_and_save_email_confirmation_token` to regenerate email confirmation tokens.
  - `send_email_confirmation_instructions` to send email confirmation instructions.
  - `email_confirmation_token_expired?` to check if the confirmation token has expired.
  - `pending_email_confirmation?` to check for pending email confirmations.
  - `confirmed?` to check if the email is confirmed.
  - `confirm_email_by_token(token)` class method to confirm email using a token.
  - `resend_email_confirmation_instructions_to(email)` class method to resend confirmation instructions.
  - `add_error_to_empty_user(param, error)` class method to add errors to a new user object.

- **Email Registration Model**:
  - Added `Shieldify::Models::EmailAuthenticatable::Registerable` module.
  - Provides registration functionality for users, including email normalization and validation.
  - Includes methods for registering a user and updating their email and password.

  **Capabilities**:
  - `register(email:, password:, password_confirmation:)` class method to register a new user.
  - `update_password(current_password:, new_password:, password_confirmation:)` to update the user's password.
  - `update_email(current_password:, new_email:)` to update the user's email.
  - `send_email_changed_notification` to notify the user when their email has been changed.
  - `send_password_changed_notification` to notify the user when their password has been changed.
  - Validates email format and uniqueness.
  - Normalizes email before validation.
  - Ensures password complexity and minimum length.
