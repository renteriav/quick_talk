class AddSingleUseTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :single_use_token, :string
  end
end
