require 'test_helper'

class JwtServiceTest < ActiveSupport::TestCase
  describe "#encode" do
    test "encode returns a valid JWT for a valid user_id" do
      user_id = 1
      result, token, jti, error = JwtService.encode(user_id)

      assert result, "The encoding should be successful"
      assert_not_nil token, "Token should not be nil"
      assert_not_nil jti, "JTI should not be nil"
      assert_nil error, "There should be no errors"
    end

    test "encode handles unexpected exceptions" do
      JWT.stub :encode, ->(*args) { raise "Unexpected error" } do
        result, token, jti, error = JwtService.encode(1)
        assert_not result, "The encoding should fail on unexpected errors"
        assert_nil token, "Token should be nil on unexpected errors"
        assert_not_nil error, "Error message should be present on unexpected errors"
      end
    end

    test "encode handles results with a block" do
      user_id = 1
      JwtService.encode(user_id) do |result, token, jti, error|
        assert result, "The encoding should be successful within block"
        assert_not_nil token, "Token should not be nil within block"
        assert_nil error, "There should be no errors within block"
      end
    end
  end

  describe "#decode" do
    test "decode returns payload for valid JWT" do
      user_id = 1
      _result, token, _jti, _error  = JwtService.encode(user_id)
      
      success, payload, error = JwtService.decode(token)
      
      assert success, "Decoding should be successful"
      assert_not_nil payload, "Payload should not be nil for a valid token"
      assert_nil error, "There should be no errors for a valid token"
    end

    test "decode with block handles valid token" do
      user_id = 1
      _result, token, _jti, _error  = JwtService.encode(user_id)
      
      JwtService.decode(token) do |success, payload, error|
        assert success, "Decoding should be successful"
        assert_not_nil payload, "Payload should not be nil for a valid token"
        assert_nil error, "There should be no errors for a valid token"
      end
    end

    test "decode handles expired tokens" do
      user_id = 1
      expired_token = JWT.encode({ sub: user_id, exp: 1.hour.ago.to_i, iss: 'Shieldify', jti: SecureRandom.hex, iat: Time.now.to_i }, JwtService.send(:secret_key), 'HS256')

      success, payload, error = JwtService.decode(expired_token)

      assert_not success, "Decoding should fail for an expired token"
      assert_nil payload, "Payload should be nil for an expired token"
      assert_equal 'Signature has expired', error, "Error should indicate that the token has expired"
    end

    test "decode handles JWT verification errors" do
      user_id = 1
      invalid_secret = 'wrong_secret'
      token = JWT.encode({ sub: user_id, exp: 24.hours.from_now.to_i }, invalid_secret, 'HS256')

      success, payload, error = JwtService.decode(token)
      
      assert_not success, "Decoding should fail due to verification error"
      assert_nil payload, "Payload should be nil when verification fails"
      assert_match /Signature verification failed/, error, "Error should indicate a verification problem"
    end

    test "decode handles invalid 'Issued At' errors" do
      user_id = 1
      future_iat = 10.minutes.from_now.to_i
      token = JWT.encode({ sub: user_id, iat: future_iat }, JwtService.send(:secret_key), 'HS256')

      success, payload, error = JwtService.decode(token)

      assert_not success, "Decoding should fail due to invalid 'Issued At'"
      assert_nil payload, "Payload should be nil when 'Issued At' is invalid"
      assert_match /Invalid issuer/, error, "Error should indicate an invalid 'Issued At' problem"
    end

    test "decode handles malformed tokens" do
      malformed_token = "not.a.real.token"
      
      success, payload, error = JwtService.decode(malformed_token)
      
      assert_not success, "Decoding should fail for a malformed token"
      assert_nil payload, "Payload should be nil for a malformed token"
      assert_match /Not enough or too many segments/, error, "Error should indicate a decoding problem"
    end

    test "decode with block handles invalid token" do
      malformed_token = "not.a.real.token"
      
      JwtService.decode(malformed_token) do |success, payload, error|
        assert_not success, "Decoding should fail for a malformed token"
        assert_nil payload, "Payload should be nil for a malformed token"
        assert_match /Not enough or too many segments/, error, "Error should indicate a decoding problem"
      end
    end
  end 
end
