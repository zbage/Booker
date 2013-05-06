class Booker
	get "/menu" do
		authenticate
		page = params[:page].nil? ? 1 : params[:page].to_i
		@supplier = Suppliers.find1(:id, params[:id])
		split_menu = SplitPage.new(Menu.find(:supplier_id, params[:id]), 8)
		@supplier_id = params[:id]
		@menu = split_menu.get_page page
		@total_page = split_menu.total_page
		erb :"menu/menu", :layout => :mainpage_layout
	end

	get "/createmenu" do
		authenticate
		@supplier = Suppliers.find1(:id, params[:id])
		erb :"menu/createmenu", :layout => :mainpage_layout
	end

	post "/createmenu" do
		authenticate
		Menu.new(params).insert
		@msg = "Created successfully!!!"
		@where_you_go = "/createmenu?id=#{params[:supplier_id]}"
		@url_text = 'Add Menu'
		erb :note, :layout => :mainpage_layout
	end

	get "/editmenu" do
		authenticate
		@menu = Menu.find1(:id, params[:id])
		@supplier = Suppliers.find1(:id, @menu.supplier_id)
		erb :"menu/editmenu", :layout => :mainpage_layout
	end

	post "/editmenu" do
		Menu.new(params).update
		@msg = "Updated successfully!!!"
		@where_you_go = "/menu?id=#{params[:supplier_id]}"
		@url_text = 'View Menus'
		erb :note, :layout => :mainpage_layout
	end

	post "/deletemenu" do
		authenticate
		supplier_id = Menu.find1(:id, params[:id]).supplier_id
		Menu.delete("id=#{params[:id]}")
		@msg = "Deleted successfully!!!"
		@where_you_go = '/menu?id=' + supplier_id.to_s
		@url_text = 'View Menus'
		erb :note, :layout => :mainpage_layout
	end

end