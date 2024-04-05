require 'test_helper'

module Shieldify
  module Models
    module EmailAuthenticatable
      class RegisterableTest < ActiveSupport::TestCase
        
        describe "validations" do
          describe "when user created" do
            describe "email validations" do
              setup do
                User = Class.new(ApplicationRecord) do
                  shieldify email_authenticatable: [:registerable]
                end
              end

              test "should email be presence if password present" do
                user_attributes = attributes_for(:user)
                user = User.create(password: user_attributes.fetch(:password))

                assert user.errors.present?
                assert_not_empty user.errors[:email]
                assert_includes user.errors[:email], "can't be blank"
              end

              test "should validate email format if email present" do
                user = User.create(email: "bad-email")

                assert user.errors.present?
                assert_not_empty user.errors[:email]
                assert_includes user.errors[:email], "is invalid"
              end

              test "should validate email uniqueness in email present" do
                user_attributes = attributes_for(:user)
                user_1 = User.create(user_attributes)

                assert user_1.persisted?

                user_2 = User.create(user_attributes)

                refute user_2.persisted?
                assert user_2.errors.present?
                assert_not_empty user_2.errors[:email]
                assert_includes user_2.errors[:email], "has already been taken"
              end
            end

            describe "password validations" do
              test "should password be presence if email present" do
                user_attributes = attributes_for(:user)
                user = User.create(email: user_attributes.fetch(:email))

                assert user.errors.present?
                assert_not_empty user.errors[:password]
                assert_includes user.errors[:password], "can't be blank"
              end

              test "should validate password complexity and lenght" do
                user = User.create(password: "bad-pas")

                assert user.errors.present?
                assert_not_empty user.errors[:password]
                assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
                assert_includes(
                  user.errors[:password],
                  "debe incluir al menos una letra mayúscula, una letra minúscula, un número y un carácter especial (@$!%*?&)"
                )
              end
            end

            describe "when no password and email" do
              test "should not validate email and password" do
                user = User.create()

                assert user.persisted?
              end
            end
          end

          describe "when user update email" do
            setup do
              User = Class.new(ApplicationRecord) do
                shieldify email_authenticatable: [:registerable]
              end
            end

            test "should validate email without password" do
              user = User.create(attributes_for(:user))

              assert user.persisted?

              user_attributes = attributes_for(:user)
              user.update(email: user_attributes.fetch(:email))

              assert_equal user.email, user_attributes.fetch(:email)
            end

            test "should validate email format without password" do
              user = User.create(attributes_for(:user))

              assert user.persisted?

              user.update(email: "bad-email")

              assert user.errors.present?
              assert_not_empty user.errors[:email]
              assert_includes user.errors[:email], "is invalid"
            end
          end

          describe "when confirmation module included" do
            setup do
              User = Class.new(ApplicationRecord) do
                shieldify email_authenticatable: [:registerable, :confirmable]
              end
            end

            describe "when user created" do
              test "should validate email and password presences" do
                user = User.create(email: "bad-email")

                assert user.errors.present?
                assert_not_empty user.errors[:email]
                assert_includes user.errors[:email], "is invalid"
                assert_not_empty user.errors[:password]
                assert_includes user.errors[:password], "can't be blank"
              end

              test "should save and prepare email confirmation" do
                user_attributes = attributes_for(:user)
                user = User.create(user_attributes)

                assert user.persisted?

                assert_empty user.email
                assert_not_nil user.unconfirmed_email
                assert_not_nil user.email_confirmation_token
                assert_equal user.unconfirmed_email, user_attributes.fetch(:email)
              end
            end

            describe "when user updated" do
              test "should save and prepare email confirmation" do
                user_attributes = attributes_for(:user)
                user = User.create(user_attributes)

                assert user.persisted?

                user.confirm_email

                assert_equal user.email, user_attributes.fetch(:email)
                assert_nil user.unconfirmed_email

                # user.update(email: attributes_for(:user).fetch(:email))

                # refute_equal user.email, user.unconfirmed_email
                # assert_not_nil user.unconfirmed_email
                # assert_not_nil user.email_confirmation_token
                # assert_equal user.unconfirmed_email, user_attributes.fetch(:email)
              end
            end
          end
        end
      end
    end
  end
end