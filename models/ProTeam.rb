require 'mysql'

class ProTeam 

 def self.load_all

    arr = Array.new
	idx = 0 
	begin    
		con = Mysql.new '127.0.0.1', 'root', 'admin'
		rs = con.query "SELECT id,name,wins,losses FROM fang.pro_team;"
		
		rs.each do |row|
		  pt = ProTeam.new
		  pt.id     = row[0]
		  pt.name   = row[1]
		  pt.wins   = row[2]
		  pt.losses = row[3]
		  arr[idx] = pt
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
   @id     = -1 
   @name   = "" 
   @wins   = 0
   @losses = 0
 end

 attr_accessor  :id, :name, :wins, :losses
  
 def to_s  
   "id: " + @id.to_s + " name: " + @name
 end

 
end