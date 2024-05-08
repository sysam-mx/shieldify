require 'jwt'

class JwtService
  @secret_key = Shieldify::Configuration.jwt_secret
  @issuer = Shieldify::Configuration.jwt_issuer
  @jwt_exp = Shieldify::Configuration.jwt_exp
  
  class << self
    # Generates a new JWT token for a user using their unique identifier.
    #
    # @param user_id [Integer] The unique identifier for the user for whom the token is being generated.
    #
    # This method constructs a JWT payload containing several fields including the user's ID, the token's
    # expiration time, and other standard JWT claims. The JWT is then encoded using the HS256 algorithm
    # with a secret key stored in the service's configuration. The method handles encoding issues and returns
    # a structured array containing the results of the token generation process.
    #
    # The method can be called with or without a block:
    #
    # Without a block, it returns an array with four elements:
    # - [Boolean] `result`: true if the token is successfully generated, false if an error occurred.
    # - [String, nil] `token`: the generated JWT token if successful, otherwise nil.
    # - [String, nil] `jti`: the unique JWT ID if successful, otherwise nil.
    # - [String, nil] `errors`: description of the error if token generation failed, otherwise nil.
    #
    # With a block, the block is yielded with the same four elements, allowing for inline handling:
    #
    # Usage Examples:
    #
    # Without a block:
    #   success, token, jti, error = JwtService.encode(user_id)
    #   if success
    #     puts "JWT generated successfully: #{token}, JTI: #{jti}"
    #   else
    #     puts "Error: #{error}"
    #   end
    #
    # With a block:
    #   JwtService.encode(user_id) do |success, token, jti, error|
    #     if success
    #       puts "JWT generated successfully: #{token}, JTI: #{jti}"
    #     else
    #       puts "Error: #{error}"
    #     end
    #   end
    #
    # This method provides a reliable way to generate JWTs with a standard set of claims and handles
    # any exceptions that may occur during the encoding process.
    def encode(user_id)
      begin
        payload = jwt_payload(user_id)
        jti = payload[:jti]
        token = JWT.encode(payload, secret_key, 'HS256')
        result = [true, token, jti, nil]
      rescue StandardError => e
        result = [false, nil, nil, e.message]
      end

      if block_given?
        yield(*result)
      else
        result
      end
    end

    # Decodes a JWT token to verify its authenticity and check if it is still valid.
    #
    # @param token [String] The JWT token to be decoded.
    #
    # This method uses JWT.decode to attempt to decode the token using a predefined secret key and issuer.
    # It handles various errors that might occur during the decoding process, such as expiration or incorrect
    # formatting of the token. It encapsulates the results and errors into a structured array format.
    #
    # The method can be called with or without a block:
    #
    # Without a block, it returns an array with three elements:
    # - [Boolean] `result`: true if the token is successfully decoded, false if an error occurred.
    # - [Hash, nil] `payload`: the decoded payload of the token if successful, otherwise nil.
    # - [String, nil] `errors`: description of the error if decoding failed, otherwise nil.
    #
    # With a block, the block is yielded with the same three elements, allowing for inline handling:
    #
    # Usage Examples:
    #
    # Without a block:
    #   success, payload, error = JwtService.decode(token)
    #   if success
    #     puts "Decoded Payload: #{payload}"
    #   else
    #     puts "Error: #{error}"
    #   end
    #
    # With a block:
    #   JwtService.decode(token) do |success, payload, error|
    #     if success
    #       puts "Decoded Payload: #{payload}"
    #     else
    #       puts "Error: #{error}"
    #     end
    #   end
    #
    # This method ensures robust handling of JWTs by validating their integrity and relevance,
    # adhering to the security settings defined by the secret_key and issuer configuration.
    def decode(token)
      decoded_token = JWT.decode(token, secret_key, true, decode_options).first
      result = [true, decoded_token, nil] # result: true (success), payload: decoded_token, errors: nil
    rescue JWT::ExpiredSignature
      result = [false, nil, 'Token has expired']
    rescue JWT::InvalidIssuerError => e
      result = [false, nil, e.message]
    rescue JWT::DecodeError => e
      result = [false, nil, e.message]
    rescue JWT::VerificationError => e
      result = [false, nil, e.message]
    rescue JWT::InvalidIatError => e
      result = [false, nil, e.message]
    rescue => e
      result = [false, nil, "Unexpected error: #{e.message}"]
    ensure
      if block_given?
        yield(*result)
      else
        result
      end
    end

    private

    def decode_options
      { algorithm: 'HS256', verify_iss: true, iss: issuer, verify_expiration: true }
    end

    def jwt_payload(user_id)
      {
        sub: user_id,
        exp: jwt_exp.hours.from_now.to_i,
        nbf: Time.now.to_i,
        iss: issuer,
        jti: SecureRandom.hex,
        iat: Time.now.to_i
      }
    end

    def secret_key
      @secret_key
    end

    def issuer
      @issuer
    end

    def jwt_exp
      @jwt_exp
    end
  end
end
