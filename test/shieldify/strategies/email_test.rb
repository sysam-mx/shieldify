require 'test_helper'

class EmailTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  def setup
    Warden.test_mode!
    @user = User.create(attributes_for(:user))
    @user.confirm_email
  end

  def teardown
    Warden.test_reset!
  end

  test "successful login" do
    post '/shfy/login', params: { email: @user.email, password: @user.password }
    assert_response :success
    assert_equal 'Bearer token', response.headers['Authorization']
  end

  test "unsuccessful login" do
    post '/shfy/login', params: { email: @user.email, password: 'wrongpassword' }
    assert_response :unauthorized
  end
end
