module ApplicationHelper
	def user_id
		 cipher = Gibberish::AES.new("p4ssw0rd")
		 return cipher.enc("#{@current_user.id}")
		 #cipher.dec("U2FsdGVkX187oKRbgDkUcMKaFfB5RsXQj/X4mc8X3lsUVgwb4+S55LQo6f6N\nIDMX")
	end

	def decrypt(data, key)
	    cipher = Gibberish::AES.new("#{key}")
	    return cipher.dec("#{data}")
    end

end
