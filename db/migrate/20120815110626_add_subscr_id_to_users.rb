class AddSubscrIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscr_id, :string
  end
end
