require 'test_helper'

class JwtStrategyTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  setup do
    Warden.test_mode!

    attributes = attributes_for(:user)
    @user = User.create(attributes)
    _success, @token, @jti, _error = JwtService.encode(@user.id)
    @user.jwt_sessions.create!(jti: @jti)
  end

  teardown do
    Warden.test_reset!
  end

  test 'successful JWT authentication' do
    post '/shfy/login', headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :success

    assert response.headers['Authorization'].start_with?('Bearer ')
  end

  test 'failed JWT authentication with invalid token' do
    post '/shfy/login', headers: { 'Authorization' => "Bearer invalidtoken" }
    assert_response :unauthorized
    assert_match /Invalid token: Not enough or too many segments/, response.body
  end

  test 'failed JWT authentication with non-whitelisted token' do
    @user.jwt_sessions.find_by(jti: @jti).destroy 
    post '/shfy/login', headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :unauthorized
    assert_match /Invalid token: session not found/, response.body
  end

  test 'failed JWT authentication with user not found' do
    User.destroy_all
    post '/shfy/login', headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :unauthorized
    assert_match /Invalid token: user not found/, response.body
  end

  test 'JWT authentication refreshes token when expired halfway' do
    travel_to Time.at((JwtService.decode(@token)[1]['exp'] - Time.now.to_i) / 2 + Time.now.to_i + 1) do
      post '/shfy/login', headers: { 'Authorization' => "Bearer #{@token}" }
      assert_response :success
      assert_not_equal @token, response.headers['auth.jwt']
    end
  end
end
