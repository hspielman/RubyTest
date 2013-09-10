require 'mysql'

class DBReport 

 def self.map_row(dbRow)
     dbr = DBReport.new
     dbr.id            = dbRow[0].to_i
     dbr.name          = dbRow[1].strip
     dbr.description   = dbRow[2].strip
     dbr.statement     = dbRow[3].strip
     dbr.type          = dbRow[4]
     
     dbr.active        = dbRow[5] == 1
     dbr.blackoutStart = dbRow[6].to_i
     dbr.blackoutEnd   = dbRow[7].to_i
     
     dbr.rowLimit      = dbRow[8].to_i
     dbr.published     = dbRow[9]  == 1
     dbr.test          = dbRow[10] == 1
     
     return dbr
 end

 def initialize()
   @id            = -1 
   @name          = "" 
   @description   = ""
   @statement     = ""
   @type          = ""       #line, bar, column, pie - or blank if none

   @active        = false
   @blackoutStart = 0
   @blackoutEnd   = 0
   
   @rowLimit      = 500 
   @published     = false
   @test          = false
   
   @stmt_arr      = Array.new
   @parm_arr      = Array.new
   @spec_map      = { }
 end
 
 def parm_arr
   @parm_arr
 end
 
 SELECT_COLS  = "SELECT id, name, description, statement, type, " + 
                " active, blackoutStart, blackoutEnd, rowLimit, published, test " + 
                " FROM db_report dbr "
               
 WHERE_ACTIVE = "WHERE active=true "  
 WHERE_PUBLIC =  WHERE_ACTIVE + " AND published=true and test=false "  
 BY_ID        = "WHERE id=? "  
             
 NAME_ORDER   = " ORDER by name ASC" 
 ID_ORDER     = " ORDER by id   ASC" 
 
 
 def self.get_list(where, orderBy, *parms)
    sqlStmt = DBReport::SELECT_COLS + " " + where + " " + orderBy + " ;"
    arr = Array.new
	 idx = 0 
    begin
        con  = DBUtil.get_connection
        stmt = con.prepare(sqlStmt)
        rs   = stmt.execute(*parms)
		  rs.each do |row|    
		    arr[idx] = self.map_row(row)
		    idx += 1
		  end    
    rescue => ex
        log = FileLogger.new("DBReport")
        log.error "Error during execute: #{sqlStmt}"
        log.error "#{ex.class} #{ex.message}"
        rows = -1
    ensure
        stmt.close if stmt
		  con.close  if con
    end    
    return arr  
 end
 
 def self.list_by_id(active)
   self.get_list(active ? DBReport::WHERE_ACTIVE : "", DBReport::ID_ORDER)
 end
 
 def self.list_by_name(active)
   self.get_list(active ? DBReport::WHERE_ACTIVE : "", DBReport::NAME_ORDER)
 end
   
 def self.list_public
   self.get_list(DBReport::WHERE_PUBLIC, DBReport::NAME_ORDER) 
 end
 
 def self.get_by_id(id)
   list = self.get_list(DBReport::BY_ID, DBReport::ID_ORDER, id) 
   return list[0]
 end
 

 def set_spec_map (map)
   @spec_map = map
 end
 
 def set_spec_orgID (id)
   @spec_map[:orgID] = id
 end
 
 def set_spec_userID (id)
   @spec_map[:userID] = id
 end
 
 attr_accessor  :id, :name, :description, :statement, :type, :active, :blackoutStart, :blackoutEnd, :rowLimit, :published, :test 
  
 def to_s  
   "id: #@id name: #@name desc: #@description active: #@active type: #@type " 
 end
  
 def blackedOut? 
  # No blackout when these times are the same
  return false  if blackoutStart == blackoutEnd
    
  hour = Time.new.hour
  
  return false if (blackoutStart < blackoutEnd) && (hour < blackoutStart || hour >= blackoutEnd)
  return false if (blackoutStart > blackoutEnd) && (hour < blackoutStart && hour >= blackoutEnd)
  
  return true 
 end
 
 def parse_statement
   @stmt_arr = Array.new
   @parm_arr = Array.new

   @statement.strip!
   return 0 if ( @statement.size == 0 )
      
   segments = @statement.split('~') 
   num_seg  = segments.size
   
   
   seq = 0 
   while seq < num_seg do
     isParm = (seq%2) == 1
     if isParm
        rptParm = DBReportParam.new(segments[seq])
        @parm_arr.push(rptParm)
     else
        @stmt_arr.push(segments[seq])  
     end
     seq += 1
   end
   
   return seq
 end 
 
 def pre_executable_statement
   parse_statement  
   exec_stmt = ""
   seq  = 0
   while seq < @stmt_arr.size
      exec_stmt += @stmt_arr[seq]
      if seq < @parm_arr.size
        rptParm = @parm_arr[seq]
        exec_stmt += rptParm.value(@spec_map)
      end
      seq += 1
   end
   
   return exec_stmt 
 end
 
 def executable_statement(parm_vals)
   parse_statement  
    
   # Set values of all DBReportParams that are NOT mapped
   seq = 0
   nvals = parm_vals == nil ? 0 : parm_vals.size
   @parm_arr.each do |rptParm|
     if !rptParm.mapped?
       val = parm_vals.shift
       rptParm.value = val
     end
   end
    
   # Now assemble the FINAL executable statement
   exec_stmt = ""
   seq  = 0
   while seq < @stmt_arr.size
     exec_stmt += @stmt_arr[seq]
      if seq < @parm_arr.size
        rptParm = @parm_arr[seq]
        exec_stmt += rptParm.value(@spec_map)
      end
      seq += 1
   end
   
   return exec_stmt    
 end
 
 
end