require 'time'

module Parse

   def self.get_int(val, default)
     begin
       useDefault = (val == nil)
       if (!useDefault) && (val.instance_of? String) && (val.length == 0) 
         useDefault = true 
       end
       iVal = useDefault ? default : val
     rescue 
       iVal = default
     end
     return iVal.to_i
   end
  
   def self.get_float(val, default)
     begin
       useDefault = (val == nil)
       if (!useDefault) && (val.instance_of? String) && (val.length == 0) 
         useDefault = true 
       end
       fVal = useDefault ? default : val
     rescue
       fVal = default
     end
     return fVal.to_f
   end

   def self.get_string(val, default)
     begin
       useDefault = (val == nil)
       if (!useDefault) && (val.instance_of? String) && (val.length == 0) 
         useDefault = true 
       end
       sVal = useDefault ? default : val
     rescue
       sVal = default
     end
     return sVal.to_s
   end

   def self.get_symbol(val, default)
     begin
       useDefault = (val == nil)
       if (!useDefault) && (val.instance_of? String) && (val.length == 0) 
         useDefault = true 
       end
       sVal = useDefault ? default : val
     rescue
       sVal = default
     end
     return sVal.to_sym
   end
   
   def self.get_boolean(val, default)
     begin
       bVal = val
       useDefault = (bVal == nil)
       if (!useDefault) && (bVal.instance_of? String) && (bVal.length == 0) 
         useDefault = true 
       end
       if useDefault
         bVal = default
       else 
         if !( (val.instance_of? TrueClass) || (val.instance_of? FalseClass) )
            val = val.to_str.downcase
            bVal = ( val == '1' || val == 'true' || val == 'on' || val == 'checked' || val[0] == 'y' )
         end     
       end
     rescue
       bVal = default
     end
     return bVal
   end
  
   def self.get_date(val, default)
     begin
       pval = (val == nil) ? default : val
		 
		 if pval.instance_of? String
		    pval = default if pval.length == 0 
		 end
		 
       if pval.instance_of? Time
          time = pval
       else
          time = Time.parse(pval.to_s)    
       end

     rescue => ex
	    puts ex.to_s
       time = default.instance_of?(Time) ? default : Time.new
     end
     return time
   end

end 
