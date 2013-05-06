class Users < SqliteHelper::Base
	def self.verify? user_name, password
		user = select1("user_name='#{user_name}'")
		expected_password = user.password
		require 'digest'
		return(expected_password == Digest::MD5.hexdigest(password))
	end
end

class Suppliers < SqliteHelper::Base; end
class Menu < SqliteHelper::Base; end
class Management < SqliteHelper::Base; end
class Cash < SqliteHelper::Base; end
class Orders < SqliteHelper::Base; end