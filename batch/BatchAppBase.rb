class BatchAppBase

   def initialize(name)
     @name    = name
     @verbose = false
   end

   def add_line(msg, trace)
      puts msg if trace
      @nLines = @arr_lines.size 
      @arr_lines[@nLines] = msg
   end
  
   def parse_parms(args, arr_lines)
      @arr_lines = arr_lines
      
      args.each do |arg|
         arg.strip!
         add_line("Arg found: #{arg}",true)
         parms = arg.split(":",2)
         operation = parms[0]
         op_value  = parms.size > 1 ? parms[1] : ""
         
         if operation == '-v'
           @verbose = true
           
         elsif operation == '-x'
           # do something else
         
         end
      end
   end

end