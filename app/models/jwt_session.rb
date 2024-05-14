class JwtSession < ActiveRecord::Base
  belongs_to :user

  validates :jti, presence: true, uniqueness: true
end