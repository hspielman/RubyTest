require 'mysql'
require_relative '../helpers/DBUtil'

class USState 

 def self.load_all

    arr = Array.new
	idx = 0 
	begin    
		con = DBUtil.get_connection
		rs  = con.query "SELECT id,name,postalCode,areaMiles,areaRank FROM usa.state;"
		
		rs.each do |row|
		  prop = USState.new
		  prop.id          = row[0].to_i
		  prop.name        = row[1]
		  prop.postalCode  = row[2]
		  prop.areaMiles   = row[3].to_f
		  prop.areaRank    = row[4].to_i
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
   @postalCode  = ""
   @areaMiles   = 0.0
   @areaRank    = 0
 end

 attr_accessor  :id, :name, :postalCode, :areaMiles, :areaRank
 
 def abbr
   @postalCode
 end
  
 def to_s  
   "postalCode: #{@postalCode} , areaRank: #{@areaRank}, areaMiles: #{@areaMiles} "
 end
 
 def to_h
   h = Hash.new
   h[:postalCode] = @postalCode
   h[:areaRank  ] = @areaRank
   h[:areaMiles ] = @areaMiles
   h
 end

 
end