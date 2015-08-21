class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.references :user, index: true
      t.string :profile_image
      t.string :logo_image
      t.string :company_name
      t.string :brand_phone
      t.string :brand_email
      t.string :brand_website
      t.string :line_one
      t.string :line_two
      t.string :keyword
      t.timestamps
    end
  end
end
