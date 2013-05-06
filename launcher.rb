require 'sinatra/base'

class Booker < Sinatra::Base
	
	if !$LOAD_PATH.include?(File.dirname(File.realpath(__FILE__)))
		$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__))) 
	end
	
	require 'util/sqlitehelper'
	SqliteHelper.db_name = 'database/booker.db'
	require 'util/splitpage'
	require 'web/models'

	set :public_folder, File.dirname(__FILE__) + '/web/public'
	set :views, File.dirname(__FILE__) + '/web/views'
	
	enable :sessions
	
	helpers do
		include Rack::Utils
		alias_method :h, :escape_html
	
		def authenticate
			if session[:user].nil?
				redirect to('/pleaselogin')
			else
				if session[:user].role != 'admin'
					redirect to('/pleaselogin')
				end
			end
		end

		def login?
			if session[:user].nil?
				redirect to('/pleaselogin')
			end
		end
	end

	get '/pleaselogin' do
		@msg = "Please Login."
		@where_you_go = '/login'
		@url_text = 'Login'
		erb :note
	end
	
	post '/test' do
		params.to_a.join(',')
	end

	Dir.new('web').grep(/\.rb$/)  {|f| require "web/#{f}"} 

	run! if app_file == $0

end