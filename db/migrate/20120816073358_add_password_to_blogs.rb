class AddPasswordToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :password, :string
  end
end
