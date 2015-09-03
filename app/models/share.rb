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
  
  validates_presence_of :phone
  
  before_validation :strip_phone
  
  before_save do
    self.share_code = create_share_code
  end

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
  
  private
    def strip_phone
      self.phone = self.phone.strip.gsub(/\D/, '')
    end
    
    def create_share_code
      share_code = loop do
        code = (0...4).map { ('A'..'Z').to_a[rand(26)] }.join
        break code unless Share.exists?(share_code: code)
      end
      return share_code
    end
  
end
