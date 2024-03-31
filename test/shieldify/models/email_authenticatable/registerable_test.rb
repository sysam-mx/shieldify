# test/models/user_test.rb
require 'test_helper'

module Shieldify
  module Models
    module EmailAuthenticatable
      class RegisterableTest < ActiveSupport::TestCase

        before do
          @valid_email = 'valid@example.com'
          @valid_password = 'ValidPass123!'
          @new_password = 'NewComplex@123'
        end

        describe 'registration' do
          it 'registers a user with valid email and password' do
            user = User.register(email: @valid_email, password: @valid_password, password_confirmation: @valid_password)
            assert user.persisted?
          end
      
          it 'does not register a user with invalid email' do
            user = User.register(email: 'invalid', password: @valid_password, password_confirmation: @valid_password)
            refute user.persisted?
            assert_not_empty user.errors[:email]
          end
      
          it 'does not register a user with a password that does not meet complexity requirements' do
            user = User.register(email: @valid_email, password: '123', password_confirmation: '123')
            refute user.persisted?
            assert_not_empty user.errors[:password]
          end
      
          it 'does not register a user when password and password_confirmation do not match' do
            user = User.register(email: @valid_email, password: @valid_password, password_confirmation: 'Mismatch123')
            refute user.persisted?
            assert_not_empty user.errors[:password_confirmation]
          end
        end

        describe 'email and password validations' do
          it 'validates presence of email on create when password is present' do
            user = User.new(password: 'ValidPassword123!', password_confirmation: 'ValidPassword123!')
            refute user.valid?
            assert_includes user.errors[:email], "can't be blank"
          end
      
          it 'validates presence of password on create when email is present' do
            user = User.new(email: 'test@example.com')
            refute user.valid?
            assert_includes user.errors[:password], "can't be blank"
          end
      
          it 'does not validate the presence of email on update' do
            user = User.create!(email: 'test@example.com', password: 'ValidPassword123!', password_confirmation: 'ValidPassword123!')
            user.reload
            user.password = 'NewValidPassword123!'
            user.password_confirmation = 'NewValidPassword123!'
            assert user.valid?
          end
      
          it 'does not validate the presence of password on update' do
            user = User.create!(email: 'test@example.com', password: 'ValidPassword123!', password_confirmation: 'ValidPassword123!')
            user.reload
            user.email = 'newtest@example.com'
            assert user.valid?
          end
        end

        describe 'password update' do
          before do
            @user = User.create!(email: 'valid@example.com', password: @valid_password, password_confirmation: @valid_password)
          end
        
          it 'updates password successfully when current password is correct' do
            @user.update_password(current_password: @valid_password, new_password: @new_password, password_confirmation: @new_password)
            assert @user.authenticate(@new_password)
          end
        
          it 'does not update password when current password is incorrect' do
            @user.update_password(current_password: 'wrongpassword', new_password: 'NewPass123!', password_confirmation: 'NewPass123!')
            assert_not @user.authenticate('NewPass123!')
            assert_includes @user.errors[:password], 'is invalid'
          end
        
          it 'does not update password when new password and password_confirmation do not match' do
            @user.update_password(current_password: @valid_password, new_password: @new_password, password_confirmation: 'Mismatch123')
            assert_not @user.authenticate("@new_password")
            assert_includes @user.errors[:password_confirmation], "doesn't match Password"
          end
        end

        describe 'email update' do
          setup do
            @user = User.create!(email: 'original@example.com', password: 'Password123!', password_confirmation: 'Password123!')
            @new_email = 'new@example.com'
          end
        
          test 'successfully updates email with correct current password' do
            assert @user.authenticate('Password123!'), 'Initial authentication should succeed'
            assert @user.update_email(current_password: 'Password123!', new_email: @new_email), 'Email should be updated with correct current password'
            assert_equal @new_email, @user.reload.email, 'Email should match the new email'
          end
        
          test 'does not update email with incorrect current password' do
            refute @user.authenticate('IncorrectPassword'), 'Authentication with incorrect password should fail'
            @user.update_email(current_password: 'IncorrectPassword', new_email: @new_email)
            assert_includes @user.errors[:password], 'is invalid', 'Should have an error for invalid password'
            refute_equal @new_email, @user.reload.email, 'Email should not change after attempt with incorrect password'
          end
        end

        it 'normalizes email before saving' do
          user = User.register(email: ' Test@Example.Com ', password: @valid_password, password_confirmation: @valid_password)
          assert_equal 'test@example.com', user.email
        end
    
        it 'does not allow duplicate emails' do
          User.create(email: @valid_email, password: @valid_password, password_confirmation: @valid_password)
          user = User.new(email: @valid_email, password: 'OtherValidPass123!', password_confirmation: 'OtherValidPass123!')
          user.valid?
          assert_includes user.errors[:email], 'has already been taken'
        end
      end
    end
  end
end