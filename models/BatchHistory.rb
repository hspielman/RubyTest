require 'mysql'
require_relative '../helpers/DBUtil'

class BatchHistory 

 INSERT_HIST = "INSERT INTO batch_history " + 
               " (jobID,execStartTsp,execEndTsp,execInfo,status) " +
               " VALUES (?,?,?,?,?) ; " 

 def self.add(jobID, started, info, status)
     DBUtil.update_object("BatchHistory", false, INSERT_HIST, 
                           jobID, started, Time.new, info, status)
 end
 
 def self.map_row(dbRow)
     bh = BatchHistory.new
     bh.id           = dbRow[0].to_i
     bh.jobID        = dbRow[1].to_i
     bh.execStartTsp = Parse.get_date(dbRow[2],nil)
     bh.execEndTsp   = Parse.get_date(dbRow[3],nil)
     bh.execInfo     = dbRow[4]
     bh.status       = dbRow[5].to_i
     return bh
 end
               
               
 SELECT_COLS = "SELECT id,jobID,execStartTsp,execEndTsp,execInfo,status " + 
               "FROM batch_history bh "
               
 FOR_JOBID   = " WHERE jobID = ? "  
 FOR_DAYS    = " WHERE execStartTsp >= DATE_SUB(now(), INTERVAL ? DAYS) "  
 BY_RECENT   = " ORDER BY execStartTsp DESC" 
 

 def self.get_list(where)
   sqlStmt = BatchHistory::SELECT_COLS + " " + where + BatchHistory::BY_RECENT + " ;"
   arr = Array.new
	idx = 0 
	begin    
		con = DBUtil.get_connection
		rs = con.query sqlStmt		
		rs.each do |row|    
		  arr[idx] = self.map_row(row)
		  idx += 1
		end    
	   
	rescue Mysql::Error => e
		p e.errno
		p e.error
      p sqlStmt
		
	ensure
		con.close if con
	end
	
	return arr
 end
 
 def initialize()
   @id     = -1 
   @jobID  = -1
   @status = -1 
 end

 attr_accessor :id, :jobID, :execStartTsp, :execEndTsp, :execInfo, :status 
  
 def to_s  
   "id: #@id job: #@jobID execAt: #@execStartTsp status: #@status" 
 end

  
end