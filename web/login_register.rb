class Booker

	get '/' do
		redirect to('/login')
	end
	
	get '/login' do
		erb :'users/login'
	end

	post '/login' do
		if Users.exist?(user_name: params[:user_name])
			if Users.verify?(params[:user_name], params[:password])
				session[:user] = Users.select1("user_name='#{params[:user_name]}'")
				redirect to('/order')
			end
		end
		@msg = "Incorrect user name or password, please try again."
		@where_you_go = '/login'
		@url_text = 'login'		
		erb :note
	end

	get '/register' do
		erb :'users/register'
	end

	post '/register' do
		if Users.exist?(user_name: params[:user_name])
			@msg = "Duplicate User Name #{params[:user_name]}."
			@where_you_go = '/register'
			@url_text = 'Register again'
		else
			params.delete("password2")
			new_user = params
			require 'digest'  
			new_user[:password] = Digest::MD5.hexdigest(new_user[:password])
			new_user[:role] = Users.all.size == 0 ? 'admin' : 'user'
			new_user[:balance] = 0
			Users.new(new_user).insert
			@msg = "User #{params[:user_name]} was created successfully, enjoy!"
			@where_you_go = '/login'
			@url_text = 'login'
		end
		erb :note
	end

	get '/edituser' do
		login?
		@user = Users.find1(:id, session[:user].id.to_i)
		erb :'users/edituser', :layout => :mainpage_layout
	end

	post '/edituser' do
		login?
		session[:user].real_name = params[:real_name]
		session[:user].email = params[:email]
		session[:user].id = session[:user].id.to_i
		session[:user].update
		@msg = "Successful!"
		@where_you_go = '/edituser'
		@url_text = 'Back'
		erb :note, :layout => :mainpage_layout
	end

	get '/logout' do
		session[:user] = nil
		redirect to('/login')
	end
	
end