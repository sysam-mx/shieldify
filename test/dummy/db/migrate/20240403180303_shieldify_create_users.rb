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

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
