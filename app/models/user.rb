# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  roles_mask             :integer          default(4)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_one :qbo_client
  has_many :clients, through: :relationships, source: :user
  has_one :brand
  
  ROLES = %i[admin accountant client]
  
  def roles=(roles)
    roles = [*roles].map { |r| r.to_sym }
    self.roles_mask = (roles & ROLES).map { |r| 2**(ROLES.index(r)) }.inject(0, :+)
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def has_role?(role)
    roles.include?(role.to_sym)
  end

  def get_accountant
    relationship = Relationship.where({ client_id: self.id })
    if relationship.any?
      relationship = relationship.last
      accountant = User.find(relationship.user_id)
    else
      false
    end
  end

  def is_admin?
    self.has_role? "admin"
  end

  def is_accountant?
    self.has_role? "accountant"
  end

  def is_client?
    self.has_role? "client"
  end
  
end
