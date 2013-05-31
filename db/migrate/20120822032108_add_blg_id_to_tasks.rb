class AddBlgIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :blg_id, :string
  end
end
