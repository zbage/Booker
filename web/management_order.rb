class Booker
		
	get '/today' do
		authenticate
		page = params[:page].nil? ? 1 : params[:page].to_i
		@max_day = SqliteHelper.execute_sql("select max(day) max_day from orders")[0][0]
		split_order = SplitPage.new(Orders.select("day='#{@max_day}'"), 8)
		@orders = split_order.get_page page
		@total_page = split_order.total_page

		@users = Users
		erb :'order/today', :layout => :mainpage_layout
	end

	post '/cancelorder' do
		authenticate
		order = Orders.find1(:id, params[:order_id])
		price = order.price.to_f
		user = Users.find1(:id, order.user_id)
		user.balance = user.balance + price
		user.update
		Orders.delete("id = #{params[:order_id]}")
		@msg = 'Successful!'
		@where_you_go = '/today'
		@url_text = 'Back'
		erb(:note, :layout => :mainpage_layout)
	end

	get '/assist' do
		authenticate
		@users = Users
		mgmt = Management.select1("1=1")
		split_menu = SplitPage.new(Menu.find(:supplier_id, mgmt.supplier_id), 8)
		page = params[:page].nil? ? 1 : params[:page].to_i
		@menus = split_menu.get_page page
		@total_page = split_menu.total_page
		erb :'order/assist', :layout => :mainpage_layout
	end

	post '/assist' do
		authenticate
		order_day = Time.now.strftime("%D")
		params[:day] = order_day
		Orders.new(params).insert
		user = Users.find1(:id, params[:user_id])
		user.balance = user.balance - params[:price].to_f
		user.update
		@msg = "Successful."
		@where_you_go = '/today'
		@url_text = 'Back'
		erb :note, :layout => :mainpage_layout
	end

end