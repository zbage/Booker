class Booker

	get '/management' do
		authenticate
		if Suppliers.all.size == 0
			@msg = "Need to add supplier first."
			@where_you_go = '/createsupplier'
			@url_text = 'Add New Supplier'
			erb :note, :layout => :mainpage_layout
		else
			if Management.all.size == 0
				@mgmt = Management.new({id: 1, open_flag: false, supplier_id: Suppliers.select1('1=1').id})
			else
				if Management.all.size != 1
					@msg = "Need to add supplier first."
					@where_you_go = '/createsupplier'
					@url_text = 'Add New Supplier'
					return(erb(:note, :layout => :mainpage_layout))
				else
					@mgmt = Management.select1('1=1')
				end
			end
			@suppliers = Suppliers.all
			@users = Users.find(:role, 'user')
			erb :'management/management', :layout => :mainpage_layout		
		end
	end

	post '/management' do
		authenticate
		Management.new(params).insert_or_update
		@msg = "Updated successfully."
		@where_you_go = '/management'
		@url_text = 'Back'
		erb(:note, :layout => :mainpage_layout)
	end

	post '/newadmin' do
		authenticate
		user = Users.find1(:id, params[:user_id].to_i)
		user.role = 'admin'
		user.update
		@msg = "Successfully."
		@where_you_go = '/management'
		@url_text = 'Back'
		erb(:note, :layout => :mainpage_layout)
	end

	post '/deleteuser' do
		authenticate
		Users.delete("id=#{params[:user_id]}")
		@msg = "Successfully."
		@where_you_go = '/management'
		@url_text = 'Back'
		erb(:note, :layout => :mainpage_layout)
	end

	get '/viewallorders' do
		authenticate
		@day = params[:day].nil? ? SqliteHelper.execute_sql("select max(day) max_day from orders")[0][0] : params[:day]
		@days = []
		SqliteHelper.execute_sql('select distinct day from orders order by 1 desc').each do |r|
			@days << r[0]
		end
		@orders = Orders.find(:day, @day)
		@users = Users
		erb(:"management/viewallorders", :layout => :mainpage_layout)
	end

	get '/viewallusers' do
		authenticate
		page = params[:page].nil? ? 1 : params[:page].to_i
		split_user = SplitPage.new(Users.all, 8)
		@total_page = split_user.total_page
		@users = split_user.get_page page
		erb :"management/viewallusers", :layout => :mainpage_layout
	end
	
	get '/viewlowusers' do
		authenticate
		page = params[:page].nil? ? 1 : params[:page].to_i
		split_user = SplitPage.new(Users.select('balance <= 20'), 8)
		@total_page = split_user.total_page
		@users = split_user.get_page page
		erb :"management/viewlowusers", :layout => :mainpage_layout
	end


end