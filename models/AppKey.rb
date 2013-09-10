require 'mysql'
require_relative '../cache/LocalProperties'
require_relative '../helpers/DBUtil'

class AppKey 

 def self.load_for_env
   
   lcCache   = LocalProperties.instance
   appEnv    = lcCache.getType
   arr = Array.new
	idx = 0 
	begin    
		con = DBUtil.get_connection
		rs  = con.query "SELECT id,env,name,value FROM app_key where env IN ( '#{appEnv}', 'all') ORDER BY name,env;"
		
		rs.each do |row|
		  prop = AppKey.new
		  prop.id          = row[0].to_i
		  prop.env         = row[1]
		  prop.name        = row[2]
		  prop.value       = row[3]
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
   @env         = 'all'
   @name        = "" 
   @value       = ""
 end

 attr_accessor  :id, :env, :name, :value
  
 def to_s  
   "name: #@name  value: #@value"
 end

 
end