class AddBranchToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :branch, :string
  end
end
