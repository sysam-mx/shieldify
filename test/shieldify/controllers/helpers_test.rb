require 'test_helper'

module Shieldify
  module Controllers
    class HelpersTest < ActionController::TestCase
      tests ApplicationController

      setup do
        @user = User.create(attributes_for(:user))
        @user.confirm_email if @user.respond_to?(:confirm_email)

        @mock_warden = OpenStruct.new
        @controller.request.env['warden'] = @mock_warden
      end

      test 'provide access to warden instance' do
        assert_equal @mock_warden, @controller.send(:warden)
      end

      describe "#current_user" do
        test 'current_user returns the logged-in user' do
          @mock_warden.user = @user
          assert_equal @user, @controller.current_user
        end

        test 'current_user returns nil when no user is logged in' do
          @mock_warden.user = nil
          assert_nil @controller.current_user, "Expected current_user to be nil when no user is logged in"
        end
      end

      describe "#user_signed_in?" do
        test 'user_signed_in? returns true when a user is logged in' do
          @mock_warden.user = @user
          assert @controller.user_signed_in?
        end
        
        test 'user_signed_in? returns false when no user is logged in' do
          @mock_warden.user = nil
          assert_not @controller.user_signed_in?
        end
      end

      describe "#authenticate_user!" do
        test 'authenticate_user! does nothing if user is logged in' do
          @mock_warden.user = @user
          assert_nothing_raised do
            @controller.authenticate_user!
          end
        end

        test 'authenticate_user! renders unauthorized if no user is logged in' do
          @mock_warden.user = nil

          assert_raises(Module::DelegationError) do
            @controller.authenticate_user!
          end
        end
      end
    end
  end
end
