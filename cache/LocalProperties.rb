require 'singleton'

class LocalProperties 

include Singleton
@@propFile = "/RubyTest/config/local_props.txt"

  def initialize 
      @nameMap = Hash.new
      File.open(@@propFile, 'r') do |properties_file|
         properties_file.read.each_line do |line|
            line.strip!
            if (line[0] != ?# and line[0] != ?=)
               i = line.index('=')
               if (i != nil)
                 nam = line[0..i - 1].strip
                 val = line[i + 1..-1].strip
                 @nameMap[nam.to_sym] = val
               end
            end
         end
      end
   end

   def getMap 
      @nameMap
   end

   def getProperty ( name, defaultValue )
     prop = @nameMap[name.to_sym]
     prop == nil ? defaultValue : prop
   end

   def getMachine 
     getProperty('machine','-')
   end

   def getType 
     getProperty('type','dev')
   end

   def isProd?
     p = getType
     p == 'prod'
   end
   
   def isTest?
     ! isProd?
   end

end

