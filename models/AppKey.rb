require 'mysql'
require_relative '../cache/LocalProperties'
require_relative '../helpers/DBUtil'

class AppKey 

 SELECT_COLS  = "SELECT id,env,name,  appID,appKey,appSecret,appToken  
                 FROM app_key ak "

 def self.load_for_env
   
   lcCache   = LocalProperties.instance
   appEnv    = lcCache.getType
   arr = Array.new
   idx = 0 
   begin    
      con  = DBUtil.get_connection
      stmt = self::SELECT_COLS + " where env IN ( '#{appEnv}', 'all') ORDER BY name,env;"
      rs  = con.query stmt
      
      rs.each do |row|
        prop = AppKey.new
        prop.id          = row[0].to_i
        prop.env         = row[1]
        prop.name        = row[2]
        
        prop.appID       = row[3]
        prop.appKey      = row[4]
        prop.appSecret   = row[5]
        prop.appToken    = row[6]
        
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
   
   @appID      = ""
   @appKey     = ""
   @appSecret  = ""
   @appToken   = ""
   
 end

 attr_accessor  :id, :env, :name,  :appID, :appKey, :appSecret, :appToken
  
 def to_s  
   "name: #@name  appID: #@appID"
 end

 
end