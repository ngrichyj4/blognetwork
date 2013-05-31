class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string "usr_id"
      t.string "grp_id"
      t.string "action"
      t.string "domain"
      t.string "qty"
      t.string "status"
      t.timestamps
    end
  end
end
