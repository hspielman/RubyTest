require_relative "../cache/LocalProperties"
require_relative "./Parse"
require 'Logger'

class FileLogger
  
  lcCache   = LocalProperties.instance
  maxSize   = Parse.get_int(lcCache.getProperty("log-MaxSize"    , ""), 25000) ;
  maxGen    = Parse.get_int(lcCache.getProperty("log-Generations", ""), 2    ) ; 
  dateFmt   = lcCache.getProperty("log-DateFormat", "%Y-%m-%d %H:%M:%S") 
  LOG_FILE  = lcCache.getProperty("log-FilePath"  , "./logs/rubyLog.txt")
 
  @@logger = Logger.new(LOG_FILE, maxGen, maxSize)
  @@logger.datetime_format = dateFmt 
  @@logger.info "** OPEN log file - maxSize=#{maxSize}, maxGen=#{maxGen}"
 
  def initialize(name)
    @name = name
    @name = "-" if name == nil
  end

  def logger 
    @@logger
  end
  
  def close
    @@logger.close if @@logger != nil
    @@logger = nil
  end
  
  def info ( message )
    @@logger.info "#@name * #{message}"
  end

  def warn ( message )
    @@logger.warn "#@name * #{message}"
  end
  
  def error ( message )
    @@logger.error "#@name * #{message}"
  end
 
  def debug ( message )
    @@logger.debug "#@name * #{message}"
  end
 
  def fatal ( message )
    @@logger.fatal "#@name * #{message}"
  end
  
end
