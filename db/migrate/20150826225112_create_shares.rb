class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.references :user, index: true
      t.integer :invitee_id
      t.string :share_code
      t.string :phone
      t.date :accepted_at
      t.timestamps
    end
    add_index :shares, :share_code, :unique => true
    add_index :shares, :invitee_id, :unique => true
  end
end
