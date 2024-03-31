# frozen_string_literal: true

class ShieldifyCreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email, null: false, default: ""
      t.string :password_digest, null: false, default: ""
      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
