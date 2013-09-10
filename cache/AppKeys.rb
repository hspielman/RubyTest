require 'singleton'
require_relative 'TimedCache'
require_relative '../models/AppKey'

class AppKeys < TimedCache

include Singleton

def initialize 
  super("AppKeys", 300)
  @nameMap   = Hash.new
  @loadCount = 0
end


def abs_getListAll
  @listAll = AppKey.load_for_env 
  @loadCount += 1
  logIt = (@loadCount%10) == 1 
  
  @nameMap.clear
  @listAll.each { |prop| @nameMap[prop.name.to_sym] = prop }  
  
  if logIt
     log = FileLogger.new(@name)
     msg = "Loaded #{@listAll.size} AppKeys - cache time is #{@cacheSeconds} seconds"
     log.info(msg)
  end
  
  @listAll
end


def getKey(name,defaultValue)
  getAll
  prop = @nameMap[name.to_sym]
  prop == nil ? defaultValue : prop.value
end

end

