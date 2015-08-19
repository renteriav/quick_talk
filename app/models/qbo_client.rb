# == Schema Information
#
# Table name: qbo_clients
#
#  id                 :integer          not null, primary key
#  token              :string(255)
#  secret             :string(255)
#  realm_id           :integer          unique
#  token_expires_at   :datetime
#  reconnect_token_at :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

class QboClient < ActiveRecord::Base
  belongs_to :user
end
