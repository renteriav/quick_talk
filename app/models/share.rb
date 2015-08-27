# == Schema Information
#
# Table name: shares
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  invitee_id  :integer
#  share_code  :string
#  phone       :string
#  accepted_at :date
#  created_at  :datetime
#  updated_at  :datetime
#

class Share < ActiveRecord::Base
	belongs_to :user, counter_cache: :count_of_shares
  #include Codable

	def after_save
	  self.update_counter_cache
	end

	def after_destroy
	  self.update_counter_cache
	end

	def update_counter_cache
	  # all shares for the user who clicked share:
	  shares = Share.where(user_id: self.user.id)
	  # for each of those shares - only count the ones where the invitee has signed in
	  # this line breaks the dashboard
	  shares.select! { |share| !share.accepted_at.nil? }
	  self.user.count_of_shares = shares.count
	  self.user.save
	end
end
