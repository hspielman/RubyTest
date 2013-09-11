require_relative '../helpers/Parse'

class DBReportParam
 
 SEPARATOR = ";"
 
 attr_reader :name, :maxLen, :hint, :html5 

 def mapped?
   @mapped
 end 
 
 def value(spec_map)
   if @mapped
     val = spec_map[@name.to_sym]
     val == nil ? "?" : val.to_s
   else
     @value
   end  
 end
 
 def value=(val)
   raise "May not set value for a MAPPED param -- resolve via spec_map" if @mapped
   
   @value = val.to_s if !val.nil?
 end
 
 def initialize(str, sep=nil)
   @name   = ""
   @maxLen = 8
   @value  = ""
   @hint   = ""
   @html5  = "text"
   @mapped = false 
   
   sep = SEPARATOR if sep.nil?
   
   str = "" if str.nil?
   str.strip!
        
   # Remove { } if string is framed by them
   if ( str.size > 1 )
     str = str[1..-2] if ( str[0] == "{" && str[-1] == "}" )
   end
   
   parts  = str.split(sep)
   nparts = parts.size
   
   if nparts > 0
     @name = parts[0] 
     if ( @name[0] == "@" )
       @mapped = true
       @name = @name[1..-1]
     end
   end

   if nparts > 1
     maxLen = Parse.get_int(parts[1], @maxLen)  
   end
   
   if nparts > 2
     type = parts[2].strip
     if ( type[0..4] == "type=" )
       @html5 = type[5..-1]
     else
       @hint = type
     end
   end
   
 end
 
 def to_s
    "name: #@name val: #@value  maxLen: #@maxLen " 
 end
 
end
