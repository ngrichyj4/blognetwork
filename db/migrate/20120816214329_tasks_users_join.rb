class TasksUsersJoin < ActiveRecord::Migration
  def up
  	 create_table :tasks_users, :id =>false do |t|
          t.integer "task_id"
          t.integer "user_id"
        end
        add_index :tasks_users, ["task_id","user_id"]
  end

  def down
  	 drop_table :tasks_users
  end
end
