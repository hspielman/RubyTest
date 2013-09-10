class TimedCache

require_relative '../helpers/FileLogger'

@@traces = false

 def setTraces (b)
   @@traces = b
 end

 def initialize(name, seconds)
    @name         = name
    @cacheSeconds = seconds
    @cacheCount   = 0
    @loadCount    = 0
    @secLoaded    = Time.now().to_i
    @listAll      = nil
    @forceReload  = false
 end
 
 def forceLoad
   @forceReload = true
   puts "forceLoad:#{@name} num-loads:#{@loadCount} times-used:#{@cacheCount}"
 end
 
 
 def mustLoad?
   secNow = Time.now().to_i
   nSec   = secNow - @secLoaded
   @forceReload || (@listAll == nil) || (nSec >= @cacheSeconds)
 end

 def getAll
   if mustLoad? 
     puts "Reloading #@name Cache" if @@traces
     @listAll     = abs_getListAll
     @secLoaded   = Time.now().to_i    
     @forceReload = false
     @loadCount += 1
     puts "#{@name} Load Count=#{@loadCount}, # Items=#{@listAll.size}" if @@traces
   end
   @cacheCount += 1
   @listAll
 end


end