class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
       t.references :user
       t.string "name"
       t.string "description"
       t.timestamps
    end
    add_index("groups","user_id")
  end
end
