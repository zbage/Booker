require "sqlite3"

module SqliteHelper
	
	def self.db_name= addr
		@@db_name = addr
	end
	
	def self.db_name
		@@db_name
	end	
	
	def self.execute_sql sql_stmt
		ret = nil
		SQLite3::Database.new(SqliteHelper.db_name) do |db|
			ret = db.execute(sql_stmt)
		end
		ret
	end


	class Base

		def self.inherited(sub_class)
			columns = nil
			SQLite3::Database.new(SqliteHelper.db_name) do |db|
				columns,  something = db.execute2( "select * from #{sub_class.to_s} where 1=0")
			end
			columns.collect! {|c| c.downcase}
			sub_class.class_eval do
				class_variable_set('@@columns', columns)
				class_variable_set('@@self_name', sub_class.to_s)
				attr_accessor *columns
				
			
				define_method :initialize do |new_record|
					new_record.each do |key, value|
						self.send("#{key}=", value)
					end					
				end
			
				define_method :insert do
					sql_stmt = %Q{
								insert into 
							#{self.class.to_s}
								values (#{self.class.class_variable_get('@@columns').collect do |c| 
														'?'
													end.join(',')})
							}
			
					bind_vars = []
					self.class.class_variable_get('@@columns').each {|c| bind_vars << self.send(c)}
					SQLite3::Database.new(SqliteHelper.db_name) do |db|
						db.execute sql_stmt, bind_vars
						id = db.execute("select max(id) from #{self.class.to_s}")[0][0]
						self.id = id
						return id
					end
				end
				
				define_method :update do
					if self.id.nil?
						insert
					else	
						sql_stmt = %Q{
							update
								#{self.class.to_s}
							set
								#{instance_variables.collect do |v|
									"#{v.to_s.gsub('@', '')} = #{instance_variable_get(v).class == String ? "'#{instance_variable_get(v)}'" : instance_variable_get(v)}"
								end.join(',')
								}
							where
								id = #{self.id}
						}
						SQLite3::Database.new(SqliteHelper.db_name) do |db|
							db.execute sql_stmt
						end
					end
					#puts sql_stmt
				end
				
				define_method :insert_or_update do
					if self.class.find1(:id, self.id).nil?
						insert
					else
						update
					end
				end				
				
				
				class << self;self;end.class_eval do
					define_method :exist? do |condition|
						filter = ''
						condition.each {|k, v| filter = "#{filter} and #{k}='#{v}'"}
						SQLite3::Database.new(SqliteHelper.db_name) do |db|
							rows = db.execute( "select 1 from #{class_variable_get('@@self_name')} where 1=1 #{filter}")
							return(rows.size == 0 ? false : true)
						end	
					end
					
					define_method :select do |condition_text|
						arr = []
						SQLite3::Database.new(SqliteHelper.db_name) do |db|
							rows = db.execute( "select * from #{class_variable_get('@@self_name')} where #{condition_text}")
							new_record = {}
							rows.each do |row|
								class_variable_get('@@columns').each_with_index do |col, i|
									new_record[col.to_sym] = row[i]
								end
								arr << self.new(new_record)
							end
						end
						arr
					end
					
					define_method :select1 do |condition_text|
						select(condition_text)[0]
					end

					define_method :all do
						select('1=1')
					end
					
					define_method :each do |&block|
						all.each &block
					end
					
					define_method :find do |what, value|
						select("#{what}='#{value}'")
					end
					
					define_method :find1 do |what, value|
						select("#{what}='#{value}'")[0]
					end
					
					define_method :delete do |condition_text|
						SQLite3::Database.new(SqliteHelper.db_name) do |db|
							db.execute( "delete from #{class_variable_get('@@self_name')} where #{condition_text}")
						end
					end
					
					
				end
				
			
			end
		end
		
	end

end