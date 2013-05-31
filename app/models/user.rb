class User < ActiveRecord::Base
  has_many :groups
  has_many :blogs, :through => :groups 
  has_and_belongs_to_many :tasks
  validates_presence_of :first_name, :last_name, :email, :password, :username
  validates_uniqueness_of :username, :email
  after_create :hash_password

  def self.password_match?(password="", user)
      user.password == Digest::SHA1.hexdigest(password)
  end

	def self.authenticate(username="", password="")
   	 	user = User.find_by_username(username)
    	if user && User.password_match?(password, user)
     		 return user
    	else
      		 return false
    	end
  	end

    def name 
      "#{first_name} #{last_name}"
    end

    #==============
    #>  Compare DB hash password, 
    #>  to provided password
    #===================

    def hash_password
      self.password = Digest::SHA1.hexdigest(self.password)
      self.save
    end

end
