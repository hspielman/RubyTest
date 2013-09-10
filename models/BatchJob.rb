require 'mysql'

class BatchJob 

 def self.map_row(dbRow)
     bj = BatchJob.new
     bj.id           = dbRow[0]
     bj.type         = dbRow[1]
     bj.name         = dbRow[2]
     bj.description  = dbRow[3]
     bj.command      = dbRow[4]

     bj.active       = dbRow[5] == 1
     bj.blocked      = dbRow[6] == 1
     bj.executionTsp = Parse.get_date(dbRow[7], nil)
     bj.executionDOW = dbRow[8].to_i      # 0 for ALL Days, 1-7 for Sun to Sat
     bj.executeOnce  = dbRow[9] == 1
     bj.mailTo       = dbRow[10]
     bj.numExecs     = dbRow[11].to_i
     return bj
 end
 
 SELECT_COLS = "SELECT bj.id,type,name,description,command,active,blocked,executionTsp,executionDOW,executeOnce,mailTo,  
                 (SELECT count(*) from batch_history bh2  
                   WHERE bh2.jobID = bj.id and DATE(bh2.execStartTsp) = DATE(now()) ) as numExecs  
                FROM batch_job bj "
               
 WHERE_ACTIVE = "WHERE bj.active=true AND bj.blocked=false "  
 
 WHERE_READY  = WHERE_ACTIVE +
               " AND ( executeOnce=false OR  DATE(executionTsp)=DATE(now()) ) 
                 AND bj.id NOT IN ( SELECT bh.jobID from batch_history bh  
                                     WHERE DATE(bh.execStartTsp) = DATE(now()) )  
                 AND ( bj.executionDOW=0 OR bj.executionDOW = DAYOFWEEK(now()) ) " 
 BY_ID = "WHERE bj.id = ? "  
             
 EXEC_ORDER = "ORDER by executionDOW ASC, HOUR(bj.executionTsp) ASC, MINUTE(bj.executionTsp) ASC, SECOND(bj.executionTsp) ASC" 
 ID_ORDER   = "ORDER by bj.id ASC" 

 def self.get_list(where, orderBy, *parms)
   sqlStmt = BatchJob::SELECT_COLS + " " + where + " " + orderBy + " ;"
   arr = Array.new
	begin    
		con  = DBUtil.get_connection
      stmt = con.prepare(sqlStmt)
      rs = stmt.execute(*parms)		
		rs.each do |row|    
		  arr.push(self.map_row(row))
		end    
	   
	rescue Mysql::Error => e
		p e.errno
		p e.error
      p sqlStmt
		
	ensure
      stmt.close if stmt
		con.close if con
	end
	
	return arr
 end
 
 
 def self.list_all_by_id(active)
   self.get_list(active ? BatchJob::WHERE_ACTIVE : "", BatchJob::ID_ORDER)
 end
 
 def self.list_all_by_exec(active)
   self.get_list(active ? BatchJob::WHERE_ACTIVE : "", BatchJob::EXEC_ORDER)
 end
 
 def self.list_ready
   self.get_list(BatchJob::WHERE_READY, BatchJob::EXEC_ORDER)
 end
 
 def self.get_by_id(id)
   theList = self.get_list(BatchJob::BY_ID, BatchJob::ID_ORDER, id)
   theObj  = if theList.size < 1 then nil else theList[0] end   
   return theObj
 end
 
 def initialize()
   @id           = -1 
   @type         = "app"
   @name         = "" 
   @description  = ""
   @command      = ""
   @active       = false
   @blocked      = true 
   @executionTsp = Time.new
   @executionDOW = 0
   @executeOnce  = false
   @mailTo       = ""
 end

 attr_accessor  :id, :type, :name, :description, :command, :active, :blocked, :executionTsp, :executionDOW, :executeOnce, :mailTo, :numExecs
  
 def to_s  
   "id: #@id name: #@name active: #@active execAt: #@executionDOW,#@executionTsp mail: #@mailTo" 
 end

 def isApplication?
   return @type == 'app'
 end
 
 def isNativeExec?
   return @type == 'exec'
 end
 
 def isDBReport?
   return @type == 'dbReport'
 end
 
 def isDBUpdate?
   return @type == 'dbUpdate'
 end
  
end