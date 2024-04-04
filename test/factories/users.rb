FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }

    transient do
      user_password { Faker::Internet.password(min_length: 10, max_length: 20, mix_case: true, special_characters: true) }
    end

    password { user_password }
    password_confirmation { user_password }
  end
end