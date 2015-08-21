# == Schema Information
#
# Table name: brands
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  profile_image :string
#  logo_image    :string
#  company_name  :string
#  brand_phone   :string
#  brand_email   :string
#  brand_website :string
#  line_one      :string
#  line_two      :string
#  keyword       :string
#  created_at    :datetime
#  updated_at    :datetime
#

class Brand < ActiveRecord::Base
  mount_uploader :logo_image, LogoUploader
  mount_uploader :profile_image, ProfileUploader
  belongs_to :user
  
  before_validation { |brand| brand.brand_phone = brand.brand_phone.to_s.gsub(/[^0-9]/, "") }
  
end
