class VerifyBatch < BatchAppBase

  def initialize
    super("VerifyBatch")
  end

  def exec_batch(args, arr_lines)
  
     parse_parms(args, arr_lines)
     
     add_line("Verify that Ruby Batch app works",true)
     
     nLines = 0 
     status = 0
     args.each do |arg|
        puts arg 
        add_line("Arg found: #{arg}",true)
        status += 1
     end
     return status
  end

end