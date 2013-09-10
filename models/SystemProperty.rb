require 'mysql'
require_relative '../helpers/DBUtil'

class SystemProperty 

 def self.load_all

    arr = Array.new
	idx = 0 
	begin    
		con = DBUtil.get_connection
		rs  = con.query "SELECT id,name,value,description,updateTsp FROM systemproperty;"
		
		rs.each do |row|
		  prop = SystemProperty.new
		  prop.id          = row[0].to_i
		  prop.name        = row[1]
		  prop.value       = row[2]
		  prop.description = row[3]
		  prop.updateTsp   = Parse.get_date(row[4],nil)
		  arr[idx] = prop
                    
		  idx += 1
		end    
	   
	rescue Mysql::Error => e
		p e.errno
		p e.error
		
	ensure
		con.close if con
	end
	
	arr

 end
 
 def initialize()
   @id          = -1 
   @name        = "" 
   @value       = ""
   @description = 0
   @updateTsp   = Time.new
 end

 attr_accessor  :id, :name, :value, :description, :updateTsp
  
 def to_s  
   "name: #@name  value: #@value  desc: #@description"
 end

 
end