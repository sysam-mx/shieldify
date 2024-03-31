# Features

## EmailAuthenticatable::Registerable Module

The `EmailAuthenticatable::Registerable` module provides a robust and flexible solution for handling user registration and authentication within your Rails application using email and password. This module is part of the `Shieldify` suite, designed to enhance security and ease the management of user credentials.

### Registration

Facilitates the creation of user accounts with email and password. Validates the presence of an email and password upon registration, ensuring data integrity.

- **Email Normalization**: Automatically normalizes email addresses by downcasing and stripping excess whitespace, reducing the chances of duplicate entries and improving data consistency.
- **Password Complexity Validation**: Enforces password complexity requirements, including the presence of uppercase and lowercase letters, numbers, and special characters, enhancing security against brute-force attacks.
- **Email Uniqueness**: Ensures that the email address used for registration is unique across the system, preventing duplicate accounts.
- **Password Update**: Allows users to securely update their passwords, including validations for current password correctness and matching new password confirmation.

#### Usage

##### Register a New User

To register a new user, utilize the `register` class method provided by the module. This method requires an email, password, and password confirmation.

```ruby
User.register(email: "user@example.com", password: "SecurePass123!", password_confirmation: "SecurePass123!")
```

##### Updating Password

Users can update their password by providing their current password, a new password, and a confirmation for the new password.

```ruby
user = User.find_by(email: "user@example.com")
user.update_password(current_password: "OldPassword123", new_password: "NewSecurePass456!", password_confirmation: "NewSecurePass456!")
```

##### Updating Email

To update a user's email, the current password and new email must be provided, ensuring that email changes are authorized.

```ruby
user = User.find_by(email: "user@example.com")
user.update_email(current_password: "CurrentPassword123", new_email: "newemail@example.com")
```

# Contributing

We welcome contributions and suggestions to improve the plugin module. Please feel free to submit pull requests or open issues with your feedback.

# License

This module is open-sourced under the MIT License. See the LICENSE file for more details.