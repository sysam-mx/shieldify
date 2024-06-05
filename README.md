# Shieldify

Shieldify is a Ruby on Rails user authentication plugin. It handles authentication through email and API authentication via JWT (JSON Web Tokens). The gem includes functionalities for user registration, email confirmation, and user authentication via email and password.

## Features

- **Authentication**:
  - **Email Authentication**: Allows users to authenticate using their email and password, generating a JWT that is managed in a whitelist.
  - **API Authentication with JWT**: Manages API authentication using JSON Web Tokens to secure requests.

- **User Management**:
  - **Email**:
    - **Registration**: Facilitates new user registration and sends confirmation emails upon registration.
    - **Confirmation**: Manages email address confirmation for user accounts through confirmation emails.

## Installation

To install the Shieldify gem, follow these steps:

Add the gem to your Gemfile:

```ruby
gem 'shieldify'
```

Run `bundle install` to install the gem:

```sh
bundle install
```

Run the Shieldify install generator to set up the necessary files and configurations:

```sh
rails generate shieldify:install
```

### Install Generator Steps

The `rails generate shieldify:install` command performs the following steps:

1. **Copy Initializer**:
    - **Description**: Copies the initializer file for Shieldify to the application's initializer directory.
    - **Generated File**: `config/initializers/shieldify.rb`
    - **Purpose**: This file is used to configure settings for Shieldify, such as JWT parameters, password complexity requirements, and other authentication-related settings.

2. **Generate Migration**:
    - **Description**: Creates a migration file to set up the users table with necessary fields for authentication.
    - **Generated File**: `db/migrate/[timestamp]_shieldify_create_users.rb`
    - **Purpose**: This migration creates the users table with fields like `email`, `password_digest`, `email_confirmation_token`, `email_confirmation_token_generated_at`, etc., which are essential for managing user authentication.

3. **Generate Model**:
    - **Description**: Generates the User model if it does not already exist.
    - **Generated File**: `app/models/user.rb`
    - **Purpose**: Defines the User model and includes necessary modules for email authentication, user registration, and email confirmation.

4. **Inject Method**:
    - **Description**: Injects the `shieldify` method call into the User model to include the necessary Shieldify modules.
    - **Injected Code**: `shieldify email_authenticatable: %i[registerable confirmable]`
    - **Purpose**: This call specifies which Shieldify modules should be included in the User model, enabling email authentication, user registration, and email confirmation functionalities.

5. **Copy Mailer Layouts**:
    - **Description**: Copies mailer layout files to the application's views directory.
    - **Generated Directory**: `app/views/layouts/shieldify`
    - **Purpose**: Provides the layout templates used for sending emails related to user authentication, such as confirmation emails and password reset emails.

6. **Copy Mailer Views**:
    - **Description**: Copies mailer view templates to the application's views directory.
    - **Generated Directory**: `app/views/shieldify/mailer`
    - **Purpose**: Provides the email templates used for various user authentication-related emails, including email confirmation instructions and email changed notification.

7. **Copy Locale File**:
    - **Description**: Copies the locale file to the application's locales directory.
    - **Generated File**: `config/locales/en.shieldify.yml`
    - **Purpose**: Contains translations for the messages and notifications used by Shieldify, ensuring that they are properly localized.

### Final Steps

Run the migrations to update your database schema:

```sh
rails db:migrate
```

Configure your mailer settings to ensure that confirmation emails are sent correctly. Update your environment configuration (e.g., `config/environments/development.rb`) with the appropriate settings.

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.example.com',
  port: 587,
  user_name: 'your_email@example.com',
  password: 'your_password',
  authentication: 'plain',
  enable_starttls_auto: true
}
```

That's it! You have successfully installed and configured the Shieldify gem in your Rails application.

## Usage

### Authentication

#### Email and Password

Authentication using email and password in this plugin provides a robust and secure way to verify users and generate JSON Web Tokens (JWT) for session management. This method leverages middleware and Warden strategies to seamlessly handle authentication requests. Below is a detailed overview of how this process works:

- **Middleware and Warden Strategy**:
  Authentication is processed through middleware that intercepts requests. If the request ends with `/shfy/login`, the Warden strategy is used to authenticate the user. If authentication is successful, a JWT is generated and sent in the response headers as `Authorization: Bearer <token>`.

  - **Shieldify Middleware**:
    The middleware intercepts requests to handle authentication based on the URL.

  - **Warden Email Strategy**:
    The Warden strategy validates the user's credentials (`email` and `password`) that have to come with the request and, if correct, generates a JWT and sends it in the response headers.

- **Custom Response**:
  In the controller (not generated by the plugin), you can return whatever you want in the body, customizing the response according to your needs.

  ```ruby
  render json: { message: 'Authenticated successfully', user: current_user }
  ```

##### Usage Example

1. **Add the Route**:

  ```ruby
  # config/routes.rb
  post '/shfy/login', to: 'sessions#create'
  ```

2. **Create the Controller that Handles the Login**:

  ```ruby
  # app/controllers/sessions_controller.rb
  class SessionsController < ApplicationController
    def create
      # Authentication will be handled by Warden

      # Custom Response
      render json: { message: 'Authenticated successfully', user: current_user }
    end
  end
  ```

3. **Example Request using curl**:

  ```sh
  curl -X POST http://localhost:3000/shfy/login -d '{
    "email": "user@example.com",
    "password": "password"
  }' -H "Content-Type: application/json"
  ```

With this setup, you can authenticate users using email and password, generate a JWT, and handle the response logic in your sessions controller or any controller.