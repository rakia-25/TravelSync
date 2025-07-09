class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one :provider
  has_many :reservations
  enum :role, {customer:"customer", provider:"provider",admin:"admin"}
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
