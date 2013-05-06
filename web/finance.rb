class Booker

	get '/finance' do
		authenticate
		page = params[:page].nil? ? 1 : params[:page].to_i
		split_user = SplitPage.new(Users.all, 8)
		@users = split_user.get_page page
		@total_page = split_user.total_page
		erb :'finance/finance', :layout => :mainpage_layout
	end

	post '/charge' do
		authenticate
		user = Users.find1(:id, params[:user_id])
		user.balance = user.balance + params[:balance].to_f
		user.update
				
		cash_item = {amount: params[:balance], 
			operater_id: session[:user].id, 
			comment: "#{user.real_name} #{params[:balance]} #{Time.now.strftime("%Y/%m/%d %H:%M")}"}
		Cash.new(cash_item).insert
		@msg = "#{user.real_name}: #{params[:balance]}"
		@where_you_go = '/finance'
		@url_text = 'Back'
		erb :note, :layout => :mainpage_layout
	end

	get '/cashflow' do
		authenticate
		page = params[:page].nil? ? 1 : params[:page].to_i
		@cash_in_hand = 0
		Cash.each {|item| @cash_in_hand = @cash_in_hand + item.amount}
		split_cash = SplitPage.new(Cash.all.reverse, 10)
		@cash = split_cash.get_page page
		@total_page = split_cash.total_page
		@users = Users
		erb :'finance/cashflow', :layout => :mainpage_layout
	end

	post '/cashflow' do
		authenticate
		amount = (params[:type] == 'pay' ? "-#{params[:amount]}" : params[:amount])
		cash_item = {amount: amount,
			operater_id: session[:user].id, 
			comment: "#{params[:comment]} #{Time.now.strftime("%Y/%m/%d %H:%M")}"}
		Cash.new(cash_item).insert
		@msg = "Successful."
		@where_you_go = '/cashflow'
		@url_text = 'Back'
		erb :note, :layout => :mainpage_layout
	end

end