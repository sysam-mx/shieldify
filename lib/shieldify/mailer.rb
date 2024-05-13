# frozen_string_literal: true

module Shieldify
  class Mailer < Shieldify::Configuration.parent_mailer.constantize
    layout 'layouts/shieldify/mailer'

    default(
      from: Shieldify::Configuration.mailer_sender,
      reply_to: Shieldify::Configuration.reply_to
    )

    def base_mailer
      initialize_email_resources(params)
      
      mail(define_headers)
    end

    private

    def define_headers
      headers = {
        to: email_to,
        subject: define_subject,
        template_path: "shieldify/mailer",
        template_name: action
      }

      headers.store(:reply_to, reply_to) if instance_variable_defined?(:@reply_to)
      headers.store(:from, from) if instance_variable_defined?(:@from)
      headers
    end

    def initialize_email_resources(options)
      options.each do |key, value|
        self.class.send(:attr_accessor, key)
        instance_variable_set("@#{key}", value)
      end
    end

    def define_subject
      I18n.t("shieldify.mailer.#{action}.subject")
    end
  end
end