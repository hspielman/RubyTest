require 'singleton'
require_relative 'TimedCache'
require_relative '../models/USState'

class USStates < TimedCache

include Singleton

def initialize 
  super("USStates", 1800)
  @abbrMap   = Hash.new
  @loadCount = 0
end


def abs_getListAll
  @listAll = USState.load_all 
  @loadCount += 1
  logIt = (@loadCount%10) == 1 
  
  @abbrMap.clear
  @listAll.each { |st| @abbrMap[st.postalCode.to_sym] = st }  
   
  if logIt
     log = FileLogger.new(@name)
     msg = "Loaded #{@listAll.size} US States - cache time is #{@cacheSeconds} seconds"
     log.info(msg)
  end
  
  @listAll
end

def list_byAbbr
  listAbbr = getAll.collect { |st| st }
  listAbbr.sort! { |a,b| a.postalCode <=> b.postalCode }
  listAbbr
end

def list_byArea
  listArea = getAll.collect { |st| st }
  listArea.sort! { |a,b| a.areaRank.to_i <=> b.areaRank.to_i }
  listArea
end


def getByPostalCode ( abbr )
  getAll
  prop = @nameMap[name.to_sym]
  prop
end

end

