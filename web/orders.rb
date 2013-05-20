class Booker

	get '/order' do
		login?
		mgmt = Management.select1("1=1")
		_12oclock = Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 00)
		if mgmt.open_flag == 'false'		
			@msg = "System doesn't open for ordering, contact your administrator."
			@where_you_go = '/user'
			@url_text = 'View My Info'
			erb :note, :layout => :mainpage_layout
		else
			order_day = ''
			if Time.now > _12oclock
				order_day = (Time.now + 86400).strftime("%D") # 1 day = 84600 second.
			else
				order_day = Time.now.strftime("%D")
			end
			if Orders.exist?(day: order_day, user_id: session[:user].id)
				@msg = "You have already ordered meal."
				@where_you_go = '/vieworders'
				@url_text = 'View My Orders'
				erb :note, :layout => :mainpage_layout
			else
				split_menu = SplitPage.new(Menu.find(:supplier_id, mgmt.supplier_id), 8)
				page = params[:page].nil? ? 1 : params[:page].to_i
				@supplier = Suppliers.find1(:id, mgmt.supplier_id)
				@menus = split_menu.get_page page
				@total_page = split_menu.total_page
				erb :'order/order', :layout => :mainpage_layout
			end
		end
	end

	post '/order' do
		login?
		user = Users.find1(:id, session[:user].id)
		if user.balance.to_f > 0
			params[:user_id] = session[:user].id
			order_day = ''
			mgmt = Management.select1("1=1")
			_12oclock = Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 00)
			if Time.now > _12oclock
				order_day = (Time.now + 86400).strftime("%D") # 1 day = 84600 second.
			else
				order_day = Time.now.strftime("%D")
			end
			params[:day] = order_day
			Orders.new(params).insert
			
			user.balance = user.balance - params[:price].to_f
			user.update
			@msg = "Successful."
			@where_you_go = '/vieworders'
			@url_text = 'View My Orders'
			erb :note, :layout => :mainpage_layout
		else
			@msg = "You have no money!!!."
			@where_you_go = '/vieworders'
			@url_text = 'View My Orders'
			erb :note, :layout => :mainpage_layout
		end
	end

	post "/usercreatemenu" do
		login?
		Menu.new(params).insert
		@msg = "Created successfully!!!"
		@where_you_go = "/order"
		@url_text = 'Order Meal'
		erb :note, :layout => :mainpage_layout
	end



	get '/vieworders' do
		login?
		page = params[:page].nil? ? 1 : params[:page].to_i
		split_order = SplitPage.new(Orders.find(:user_id, session[:user].id), 8)
		@total_page = split_order.total_page
		@orders = split_order.get_page page
		
		order_day = ''
		mgmt = Management.select1("1=1")
		hour_minute = mgmt.end_time.split(':')
		_12oclock = Time.new(Time.now.year, Time.now.month, Time.now.day, hour_minute[0], hour_minute[1])
		if Time.now > _12oclock
			order_day = (Time.now + 86400).strftime("%D") # 1 day = 84600 second.
		else
			order_day = Time.now.strftime("%D")
		end

		@cancelable_orders = Orders.select("user_id=#{session[:user].id} and day='#{order_day}'")
		@txt = "user_id=#{session[:user].id} and day='#{order_day}'"
		erb :'order/vieworders', :layout => :mainpage_layout
	end

end  