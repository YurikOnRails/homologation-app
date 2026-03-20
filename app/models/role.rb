class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  validates :name, presence: true, uniqueness: true,
                   inclusion: { in: %w[super_admin coordinator teacher student] }
end
