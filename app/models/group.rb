class Group < ActiveRecord::Base
	has_many :blogs
	belongs_to :user

	validates_presence_of :name
end
