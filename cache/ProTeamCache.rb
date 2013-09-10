require_relative 'TimedCache'
require 'singleton'

class ProTeamCache < TimedCache

include Singleton

def initialize 
  super("ProTeam", 15)
  @idMap = Hash.new
end


def abs_getListAll
  @listAll = ProTeam.load_all 
  @idMap.clear
  @listAll.each { |pt| @idMap[pt.id.to_sym] = pt }  
  @listAll
end


def get_byId ( id )
  getAll
  @idMap[id.to_s.to_sym]
end

end
