require 'test_helper'

module Users
  module Emails
    class ResetPasswordsControllerTest < ActionDispatch::IntegrationTest
      setup do
        attributes = attributes_for(:user)
        @user = User.create(attributes)
        @user.confirm_email
        @valid_email = @user.email
        @invalid_email = 'invalid@example.com'
        @user.generate_reset_email_password_token
        @reset_token = @user.reset_email_password_token
      end

      test 'successful password reset request' do
        post users_request_password_recovery_path, params: { email: @valid_email }
        assert_response :redirect
        assert_redirected_to Shieldify::Configuration.after_request_reset_password_url

        assert_equal I18n.t("shieldify.controllers.emails.reset_passwords.create.success"), response.headers['X-Password-Reset-Message']
        assert_equal 'success', response.headers['X-Password-Reset-Status']
      end

      test 'unsuccessful password reset request with invalid email' do
        post users_request_password_recovery_path, params: { email: @invalid_email }
        assert_response :redirect
        assert_redirected_to Shieldify::Configuration.after_request_reset_password_url

        assert_equal I18n.t("shieldify.controllers.emails.reset_passwords.create.failure"), response.headers['X-Password-Reset-Message']
        assert_equal 'error', response.headers['X-Password-Reset-Status']
      end

      test 'successful password reset' do
        put users_reset_password_path, params: {
          token: @reset_token,
          password: 'P@$$word10',
          password_confirmation: 'P@$$word10'
        }

        assert_response :redirect
        assert_redirected_to Shieldify::Configuration.after_reset_password_url

        assert_equal I18n.t("shieldify.controllers.emails.reset_passwords.update.success"), response.headers['X-Password-Reset-Message']
        assert_equal 'success', response.headers['X-Password-Reset-Status']

        @user.reload
        assert @user.authenticate('P@$$word10')
      end

      test 'unsuccessful password reset with invalid token' do
        put users_reset_password_path, params: {
          token: 'invalidtoken',
          password: 'newpassword',
          password_confirmation: 'newpassword'
        }
        assert_response :redirect
        assert_redirected_to Shieldify::Configuration.after_reset_password_url

        assert_equal I18n.t("shieldify.controllers.emails.reset_passwords.update.failure"), response.headers['X-Password-Reset-Message']
        assert_equal 'error', response.headers['X-Password-Reset-Status']

        @user.reload
        assert_not @user.authenticate('newpassword')
      end

      test 'unsuccessful password reset with mismatched password confirmation' do
        put users_reset_password_path, params: {
          token: @reset_token,
          password: 'newpassword',
          password_confirmation: 'differentpassword'
        }
        assert_response :redirect
        assert_redirected_to Shieldify::Configuration.after_reset_password_url

        assert_match /Password confirmation doesn't match/, response.headers['X-Password-Reset-Message']
        assert_equal 'error', response.headers['X-Password-Reset-Status']

        @user.reload
        assert_not @user.authenticate('newpassword')
      end

      test 'unsuccessful password reset with weak password' do
        put users_reset_password_path, params: {
          token: @reset_token,
          password: 'short',
          password_confirmation: 'short'
        }
        assert_response :redirect
        assert_redirected_to Shieldify::Configuration.after_reset_password_url

        assert_match /Password is too short/, response.headers['X-Password-Reset-Message']
        assert_equal 'error', response.headers['X-Password-Reset-Status']

        @user.reload
        assert_not @user.authenticate('short')
      end
    end
  end
end