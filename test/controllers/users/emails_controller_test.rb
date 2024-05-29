require 'test_helper'

module Users
  class EmailsControllerTest < ActionDispatch::IntegrationTest
    setup do
      attributes = attributes_for(:user)
      @user = User.create(attributes)
      @token = @user.email_confirmation_token
    end

    test 'successful email confirmation' do
      get users_email_confirmation_path(token: @token)
      assert_response :ok

      json_response = JSON.parse(response.body)
      assert_equal 'Email successfully confirmed', json_response['message']

      @user.reload
      assert @user.email.present?
      assert_nil @user.unconfirmed_email
      assert_nil @user.email_confirmation_token
      assert_nil @user.email_confirmation_token_generated_at
    end

    test 'unsuccessful email confirmation with invalid token' do
      invalid_token = 'invalidtoken'
      get users_email_confirmation_path(token: invalid_token)
      assert_response :unprocessable_entity

      json_response = JSON.parse(response.body)
      assert_includes json_response['errors'], 'Email confirmation token invalid'

      @user.reload
      assert_empty @user.email
      assert @user.unconfirmed_email.present?
      assert @user.email_confirmation_token.present?
      assert @user.email_confirmation_token_generated_at.present?
    end
  end
end
