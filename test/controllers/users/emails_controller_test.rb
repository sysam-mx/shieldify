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
      assert_response :redirect
      assert_redirected_to Shieldify::Configuration.before_confirmation_url

      assert_equal 'Email successfully confirmed', cookies['shfy_message']
      assert_equal 'success', cookies['shfy_status']

      @user.reload
      assert @user.email.present?
      assert_nil @user.unconfirmed_email
      assert_nil @user.email_confirmation_token
      assert_nil @user.email_confirmation_token_generated_at
    end

    test 'unsuccessful email confirmation with invalid token' do
      invalid_token = 'invalidtoken'
      get users_email_confirmation_path(token: invalid_token)
      assert_response :redirect
      assert_redirected_to Shieldify::Configuration.before_confirmation_url

      assert_equal 'Email confirmation token invalid', cookies['shfy_message']
      assert_equal 'error', cookies['shfy_status']

      @user.reload
      assert_empty @user.email
      assert @user.unconfirmed_email.present?
      assert @user.email_confirmation_token.present?
      assert @user.email_confirmation_token_generated_at.present?
    end
  end
end
