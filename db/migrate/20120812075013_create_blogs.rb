class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.references :group
      t.string "name"
      t.string "url"
      t.string "status"
      t.timestamps
    end
    add_index("blogs","group_id")
  end
end
