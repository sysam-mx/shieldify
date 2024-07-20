# frozen_string_literal: true

class ShieldifyCreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      ## Email registerable
      t.string :email, default: ""
      t.string :password_digest, default: ""

      ## Email confirmable
      t.string :unconfirmed_email
      t.string :email_confirmation_token
      t.string :email_confirmation_token_generated_at

      ## Email password recoverable
      t.string :reset_email_password_token
      t.string :reset_email_password_token_generated_at

      t.timestamps null: false
    end

    create_table :jwt_sessions do |t|
      t.string :jti, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :users, :email
    add_index :jwt_sessions, :jti, unique: true
  end
end
