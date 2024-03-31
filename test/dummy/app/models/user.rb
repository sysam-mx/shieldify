class User < ApplicationRecord
  shieldify email_authenticatable: [:registerable]
end