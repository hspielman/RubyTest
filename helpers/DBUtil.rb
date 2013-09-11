require 'time'
require 'mysql'
require_relative '../cache/LocalProperties'
require_relative '../helpers/FileLogger'

# See: http://tmtm.org/en/mysql/ruby/  ,  http://rubydoc.info/gems/mysql/2.8.1/frames

module DBUtil

  DOW_NAMES = [ 'all','Mon','Tue','Wed','Thu','Fri','Sat','Sun' ]
  
  def self.dow_name(idx)
    begin
      self::DOW_NAMES[idx]
    rescue => ex
      puts ex.to_s
      idx
    end
  end

 
  FORMAT_TSP = "%Y-%m-%d %H:%M:%S"  
  def self.tsp_fmt(time)
    time.strftime(self::FORMAT_TSP)
  end
  
  def self.bool_fmt(bool)
    if bool then 1 else 0 end
  end
  
    
  lcCache  = LocalProperties.instance
  @@dbAddr = lcCache.getProperty("dbAddr", "127.0.0.1")
  @@dbUser = lcCache.getProperty("dbUser", "admin")
  @@dbPass = lcCache.getProperty("dbPass", "none" )
  @@dbName = lcCache.getProperty("dbName", "trkr" )

  def self.get_conn(db_name)
	 con = Mysql.new @@dbAddr, @@dbUser, @@dbPass, db_name
    con
  end

  def self.get_connection
	self.get_conn(@@dbName)
  end

  def self.exec_query(name, statement)
    rs = nil 
    log = FileLogger.new("DBUtil")
    begin
        log.info "Exec Query: #{statement} "
        con = self.get_connection
        rs  = con.query(statement)
    rescue => ex
        log = FileLogger.new("DBUtil")
        log.error "Error during query: #{statement}"
        log.error "#{ex.class} #{ex.message}"
    ensure
		  con.close if con
    end    
    return rs
  end
 
  def self.exec_update(name, statement)
     rows = 0
     log = FileLogger.new("DBUtil")
     begin
        log.info "Exec Update: #{statement} "
        con  = self.get_connection
        stmt = con.prepare(statement)
        stmt.execute
        rows = con.affected_rows
     rescue => ex
        log.error "Error during execute: #{statement}"
        log.error "#{ex.class} #{ex.message}"
        rows = -1
    ensure
        stmt.close if stmt
		  con.close  if con
     end    
     return rows  
  end
 
 
  def self.update_object(name, logIt, statement, *parms)
    rows = 0
    log = FileLogger.new(name)
    begin
        log.info("Exec Update: #{statement}") if logIt
        con  = self.get_connection
        stmt = con.prepare(statement)
        stmt.execute(*parms)
        rows = con.affected_rows
    rescue => ex
        log.error "Error during update: #{statement}"
        log.error "#{ex.class} #{ex.message}"
        rows = -1
   ensure
        stmt.close if stmt
		  con.close  if con
    end    
    return rows  
  end

end 
