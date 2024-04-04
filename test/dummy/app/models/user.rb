class User < ApplicationRecord
  shieldify email_authenticatable: %i[registerable confirmable]
end