module CacheInit

   def CacheInit.reload_all
      classes = ['AppKeys','SystemProperties','USStates']
      nLoads = 0
      nErrs  = 0
      classes.each do |className| 
        # Get just the class name from the file name

        # See if the class implements forceLoad method, and is NOT the TimedCache base class
        # If so, call forceLoad method on the class  
        
        begin
           className.strip!
           cInst = Kernel.const_get(className).instance
           if cInst.respond_to?(:forceLoad)
             cInst.forceLoad
             nLoads += 1
           end
           
        rescue => ex
           puts ex.to_s
           nErrs += 1
        end
        
      end
      
      " Reloads Forced:#{nLoads}  Errors:#{nErrs}"
   end

end