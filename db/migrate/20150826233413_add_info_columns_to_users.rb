class AddInfoColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first, :string
    add_column :users, :last, :string
    add_column :users, :phone, :string
    add_column :users, :count_of_shares, :integer
  end
end
