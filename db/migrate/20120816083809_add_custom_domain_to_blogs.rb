class AddCustomDomainToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :custom_domain, :string
  end
end
