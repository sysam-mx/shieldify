require 'test_helper'

module Shieldify
  class MailerTest < ActionMailer::TestCase

    setup do
      @options = {
        user: create(:user),
        action: 'confirmation_instructions',
        images: {'logo.png' => "#{file_fixture_path}/logo_example.png"},
        files: {'file.pdf' => "#{file_fixture_path}/file_example.pdf"}
      }
    end

    test "base_mailer sends an email with correct headers" do
      email = Shieldify::Mailer.with(@options).base_mailer.deliver_now

      assert_emails 1
      assert_equal ['shieldify@example.com'], email.from
      assert_equal [@options[:user].email], email.to
      assert_equal 'Welcome subject', email.subject
    end

    test "base_mailer attaches images" do
      email = Shieldify::Mailer.with(@options).base_mailer.deliver_now

      assert_not email.attachments['logo.png'].nil?
      # assert_equal email.attachments['logo.png'].read, File.read(@options[:images]['logo.png'])
    end

    test "base_mailer attaches files" do
      email = Shieldify::Mailer.with(@options).base_mailer.deliver_now

      assert_not email.attachments['file.pdf'].nil?
      # assert_equal email.attachments['file.pdf'].read, File.read(@options[:files]['file.pdf'])
    end
  end
end