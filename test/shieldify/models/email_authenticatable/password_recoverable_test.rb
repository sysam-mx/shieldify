require 'test_helper'

module Shieldify
  module Models
    class EmailAuthenticatablePasswordRecoverableTest < ActiveSupport::TestCase
      setup do
        @user = User.create(
          email: 'test@example.com',
          password: 'P@$$word1',
          password_confirmation: 'P@$$word1'
        )
        @user.confirm_email
      end

      describe "callbacks" do
        describe "when password is changed" do
          test "should clear reset email password token" do
            @user.generate_reset_email_password_token
            @user.update(password: 'newP@$$word1', password_confirmation: 'newP@$$word1')
            @user.reload

            assert_nil @user.reset_email_password_token
            assert_nil @user.reset_email_password_token_generated_at
          end
        end
      end

      describe "#generate_reset_email_password_token" do
        test "should generate reset email password token" do
          @user.generate_reset_email_password_token
          assert @user.reset_email_password_token.present?
          assert @user.reset_email_password_token_generated_at.present?
          assert @user.reset_email_password_token_generated_at >= 2.hours.ago
        end
      end

      describe "#send_reset_email_password_instructions" do
        test "should send reset email password instructions" do
          @user.generate_reset_email_password_token
          assert_difference 'ActionMailer::Base.deliveries.size', +1 do
            @user.send_reset_email_password_instructions
          end

          last_email = ActionMailer::Base.deliveries.last
          assert_equal @user.email, last_email.to.first
          assert_includes last_email.body.encoded, @user.reset_email_password_token
        end
      end

      describe "#reset_password" do
        describe "with valid token and matching confirmation" do
          test "should reset password successfully" do
            @user.generate_reset_email_password_token
            result = @user.reset_password(
              new_password: 'newP@$$word1',
              new_password_confirmation: 'newP@$$word1'
            )

            assert result
            assert @user.authenticate('newP@$$word1')
            assert_nil @user.reset_email_password_token
            assert_nil @user.reset_email_password_token_generated_at
          end
        end

        describe "with mismatched confirmation" do
          test "should not reset password" do
            @user.generate_reset_email_password_token
            result = @user.reset_password(
              new_password: 'newP@$$word1',
              new_password_confirmation: 'differentpassword'
            )

            refute result
            assert_includes @user.errors[:password_confirmation], "doesn't match Password"
            assert_not @user.authenticate('newP@$$word1')
          end
        end

        describe "with invalid token" do
          test "should not reset password" do
            @user.generate_reset_email_password_token
            @user.update(reset_email_password_token_generated_at: 3.hours.ago) # Token expired

            result = @user.reset_password(
              new_password: 'newP@$$word1',
              new_password_confirmation: 'newP@$$word1'
            )

            refute result
            assert_includes @user.errors[:reset_email_password_token], "is invalid or has expired"
            assert_not @user.authenticate('newP@$$word1')
          end
        end

        describe "with password not meeting requirements" do
          test "should not reset password" do
            @user.generate_reset_email_password_token
            result = @user.reset_password(
              new_password: 'who',
              new_password_confirmation: 'who'
            )

            refute result
            assert_includes @user.errors[:password], "is too short (minimum is 8 characters)"
            assert_includes @user.errors[:password], "It must include at least one uppercase letter, one lowercase letter, one number, and one special character (@$!%*?&)"
          end
        end
      end

      describe ".find_by_reset_email_password_token" do
        test "should find user with valid token" do
          @user.generate_reset_email_password_token
          result = User.find_by_reset_email_password_token(@user.reset_email_password_token)
          assert_equal @user, result
        end

        test "should return nil with invalid token" do
          result = User.find_by_reset_email_password_token('invalid-token')
          assert_nil result
        end

        test "should return nil if no token is present" do
          @user.update(reset_email_password_token: nil)
          result = User.find_by_reset_email_password_token(nil)
          assert_nil result
        end
      end
    end
  end
end
