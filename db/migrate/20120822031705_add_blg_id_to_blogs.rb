class AddBlgIdToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :blg_id, :string
  end
end
