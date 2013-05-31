class AddDemoUserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :demo_user, :boolean
  end
end
