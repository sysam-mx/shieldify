require 'test_helper'

module Shieldify
  module Models
    module EmailAuthenticatable
      class ConfirmableTest < ActionMailer::TestCase
        setup do
          ActionMailer::Base.deliveries.clear
        end

        describe "callbacks" do
          describe "when user created" do
            setup do
              User = Class.new(ApplicationRecord) do
                shieldify email_authenticatable: [:confirmable]
              end
            end

            test "should generate email confirmation and sent instructions" do
              user_attrubutes = attributes_for(:user)
              unconfirmed_email = user_attrubutes.fetch(:email)
              user = User.create(user_attrubutes)

              # generate email confirmation
              assert_equal user.unconfirmed_email, unconfirmed_email
              assert_not_nil user.email_confirmation_token
              assert_not_nil user.email_confirmation_token_generated_at
              assert_empty user.email
              assert user.persisted?

              # send email confirmation instructions
              assert_emails 1
              email = ActionMailer::Base.deliveries.last
              assert_equal [unconfirmed_email], email.to
              assert_equal I18n.t("shieldify.mailer.email_confirmation_instructions.subject"), email.subject
            end
          end

          describe "when update email" do
            test "should generate email confirmation and sent instructions" do
              user = User.create(attributes_for(:user))

              assert_emails 1
              email = ActionMailer::Base.deliveries.last
              assert_equal [user.unconfirmed_email], email.to
              assert_equal I18n.t("shieldify.mailer.email_confirmation_instructions.subject"), email.subject

              User.confirm_email_by_token(user.email_confirmation_token)
              params = attributes_for(:user)
              user.reload
              user.update(email: params.fetch(:email))

              # generate email confirmation
              assert_equal user.unconfirmed_email, params.fetch(:email)
              assert_not_nil user.email_confirmation_token
              assert_not_nil user.email_confirmation_token_generated_at
              refute_empty user.email
              assert_equal user.email, user.email_was

              # send email confirmation instructions
              assert_emails 2
              email = ActionMailer::Base.deliveries.last
              assert_equal [params.fetch(:email)], email.to
              assert_equal I18n.t("shieldify.mailer.email_confirmation_instructions.subject"), email.subject
            end
          end
        end

        describe "#confirm_email_by_token" do
          describe "when valid token" do
            test "should confirm the email" do
              new_user = User.create(attributes_for(:user))
              unconfirmed_email = new_user.unconfirmed_email
              user = User.confirm_email_by_token(new_user.email_confirmation_token)

              assert_equal user.email, unconfirmed_email
              assert_nil user.unconfirmed_email
              assert_nil user.email_confirmation_token
            end
          end

          describe "when invalid token" do
            test "should return and error" do
              new_user = User.create(attributes_for(:user))
              unconfirmed_email = new_user.unconfirmed_email
              new_user.reload
              user = User.confirm_email_by_token("invalid-token")

              assert_empty new_user.email
              assert_not_nil new_user.unconfirmed_email
              assert_not_nil new_user.email_confirmation_token
              assert user.errors.present?
              assert_not_empty user.errors[:email_confirmation_token]
              assert_includes user.errors[:email_confirmation_token], "is not valid"
            end
          end

          describe "when token expired" do
            test "should return and error" do
              new_user = User.create(attributes_for(:user))
              unconfirmed_email = new_user.unconfirmed_email
              new_user.update(email_confirmation_token_generated_at: 34.hours.ago)
              user = User.confirm_email_by_token(new_user.email_confirmation_token)

              assert_empty new_user.email
              assert_not_nil new_user.unconfirmed_email
              assert_not_nil new_user.email_confirmation_token
              assert user.errors.present?
              assert_not_empty user.errors[:email_confirmation_token]
              assert_includes user.errors[:email_confirmation_token], "has expired"
            end
          end
        end

        describe "#resend_email_confirmation_instructions_to" do
          test "should not resend email confirmation instructions if unconfirmed_email does not exist" do
            user = User.resend_email_confirmation_instructions_to("nonexistent@example.com")

            assert user.errors.present?
            assert_not_empty user.errors[:unconfirmed_email]
            assert_includes user.errors[:unconfirmed_email], "not found"
            assert_emails 0
          end

          test "should reset email confirmation token" do
            new_user = User.create(attributes_for(:user))
            first_email_confirmation_token = new_user.email_confirmation_token
            first_email_confirmation_token_generated_at = new_user.email_confirmation_token_generated_at

            sleep 1

            user = User.resend_email_confirmation_instructions_to(new_user.unconfirmed_email)
            second_email_confirmation_token = user.email_confirmation_token
            second_email_confirmation_token_generated_at = user.email_confirmation_token_generated_at

            assert_equal new_user.unconfirmed_email, user.unconfirmed_email
            refute_equal first_email_confirmation_token, second_email_confirmation_token
            refute_equal first_email_confirmation_token_generated_at , second_email_confirmation_token_generated_at
            assert_operator first_email_confirmation_token_generated_at, :<, second_email_confirmation_token_generated_at
          end
        
          test "should resend email confirmation instructions to user pending confirmation" do
            new_user = User.create(attributes_for(:user))

            assert_emails 1
            email = ActionMailer::Base.deliveries.last
            assert_equal [new_user.unconfirmed_email], email.to
            assert_equal I18n.t("shieldify.mailer.email_confirmation_instructions.subject"), email.subject

            user = User.resend_email_confirmation_instructions_to(new_user.unconfirmed_email)

            assert_emails 2
            email = ActionMailer::Base.deliveries.last
            assert_equal [user.unconfirmed_email], email.to
            assert_equal I18n.t("shieldify.mailer.email_confirmation_instructions.subject"), email.subject
          end
        end

        test "#confirm_email" do
          skip "Pending implementation, see #{__FILE__}:#{__LINE__ + 1}"
        end

        test "regenerate_and_save_email_confirmation_token" do
          skip "Pending implementation, see #{__FILE__}:#{__LINE__ + 1}"
        end

        test "send_email_confirmation_instructions" do
          skip "Pending implementation, see #{__FILE__}:#{__LINE__ + 1}"
        end

        test "email_confirmation_token_expired?" do
          skip "Pending implementation, see #{__FILE__}:#{__LINE__ + 1}"
        end

        test "pending_email_confirmation?" do
          skip "Pending implementation, see #{__FILE__}:#{__LINE__ + 1}"
        end
        
        test "skip_email_confirmation_callbacks?" do
          skip "Pending implementation, see #{__FILE__}:#{__LINE__ + 1}"
        end

        test "confirmed?" do
          skip "Pending implementation, see #{__FILE__}:#{__LINE__ + 1}"
        end
      end
    end
  end
end