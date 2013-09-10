require 'singleton'
require_relative 'TimedCache'

class SystemProperties < TimedCache

include Singleton

def initialize 
  super("SystemProperties", 300)
  @nameMap   = Hash.new
  @loadCount = 0
end


def abs_getListAll
  @listAll = SystemProperty.load_all 
  @loadCount += 1
  logIt = (@loadCount%10) == 1 
  
  @nameMap.clear
  @listAll.each { |prop| @nameMap[prop.name.to_sym] = prop }  
  
  if logIt
     log = FileLogger.new(@name)
     msg = "Loaded #{@listAll.size} props - cache time is #{@cacheSeconds} seconds"
     log.info(msg)
  end
  
  @listAll
end


def getProperty ( name, defaultValue )
  getAll
  prop = @nameMap[name.to_sym]
  prop == nil ? defaultValue : prop.value
end

end

