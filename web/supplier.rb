class Booker

	get '/suppliers' do
		authenticate
		page = params[:page].nil? ? 1 : params[:page].to_i
		splite_supplier = SplitPage.new(Suppliers.all, 5)
		@total_page = splite_supplier.total_page
		@suppliers = splite_supplier.get_page page
		erb :"supplier/suppliers", :layout => :mainpage_layout
	end

	get '/createsupplier' do
		authenticate
		erb :"supplier/createsupplier", :layout => :mainpage_layout
	end

	post '/createsupplier' do
		authenticate
		if Suppliers.exist?(supplier_name: params[:supplier_name])
			@msg = "Failed: Duplicate User Name #{params[:supplier_name]}."
			@where_you_go = '/createsupplier'
			@url_text = 'Create again'
		else
			new_supplier = params
			new_supplier[:active_fg] = 'false'
			Suppliers.new(new_supplier).insert
			@msg = "Supplier #{params[:supplier_name]} was created successfully!!!"
			@where_you_go = '/suppliers'
			@url_text = 'View Suppliers'
		end
		erb :note, :layout => :mainpage_layout
	end

	get '/editsupplier' do
		authenticate
		@supplier = Suppliers.find1(:id, params[:id])
		erb :"supplier/editsupplier", :layout => :mainpage_layout
	end

	post '/editsupplier' do
		authenticate
		Suppliers.new(params).update
		@msg = "Supplier #{params[:supplier_name]} was updated successfully!!!"
		@where_you_go = '/suppliers'
		@url_text = 'View Suppliers'
		erb :note, :layout => :mainpage_layout
	end

	post '/deletesupplier' do
		authenticate
		Suppliers.delete("id=#{params[:id]}")
		@msg = "Deleted successfully!!!"
		@where_you_go = '/suppliers'
		@url_text = 'View Suppliers'
		erb :note, :layout => :mainpage_layout
	end


end