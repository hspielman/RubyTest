require_relative '../mail/MailFactory'
require_relative '../cache/LocalProperties'
require_relative '../helpers/DBUtil'
require 'erb'

class BatchJobExec

# Execute a BatchJob as one of:
#   a DBReport, 
#   a DBUpdate, 
#   a Native App or Shell Script, 
#   a Ruby class that implements exec_batch(args, out_lines)

@@lcCache = LocalProperties.instance

 def execute(bj, out_lines = nil, emailOK = false, manual = false)
   logger    = FileLogger.new("BatchExec")
	out_lines = Array.new if out_lines.nil?
	howRun    = manual ? "Manual" : "Scheduled"
   msg       = "Job #{bj.id} #{howRun} Exec = [#{bj.type}] #{bj.name} " + (bj.blocked ? " ** IS BLOCKED **" : " ** Starting **")
	puts msg
   out_lines.push(msg)
   logger.info(msg)          
   return -1 if bj.blocked
   
   status  = 0
   result  = ''
   infoMsg = ''
   startTsp = Time.new
   logger.info("  #{bj.command}")          
   
   begin
      out_lines.push("Job #{bj.id} #{@name} : #{bj.command}\n")
      
      if bj.isDBReport?
         # Run a DB Report
         rs = DBUtil.exec_query(bj.name, bj.command)
         if ( rs != nil )
           rs.each do |row|
              rval = row.to_s 
              out_lines.push(rval)
              status += 1
           end
         end
         
      elsif bj.isDBUpdate?
         # Run a DB Update
         status = DBUtil.exec_update(bj.name, bj.command)
         msg   = "#{status} Rows Updated\n"
         out_lines.push(msg)
      
      elsif bj.isNativeExec?
         # Run native process or script
         pipe = open("|#{bj.command}")
         eof = false
         while !eof do
           line = pipe.gets
           eof  = line.nil?
           out_lines.push(line) if !line.nil?
         end
         pipe.close         
         status = 1
         
      else
         # Run the Ruby class with the command parameters
         begin
            cmd  = bj.command
            raise 'Command is empty' if (cmd.nil? || cmd.length == 0)            
            cmd.strip!
            args = cmd.split(" ")
            className = args.shift
            className.strip!
            require_relative "./#{className}"
            bRef = Kernel.const_get(className).new
            if bRef.respond_to?(:exec_batch)
               status = bRef.exec_batch(args, out_lines)
            else
               msg = "Class #{className} does not implement exec_batch(args, out_lines)\n"
               puts msg
               out_lines.push(msg)
            end
         rescue => ex
            puts "Exception running Job #{bj.id}" + ex.to_s
         end
      end
      
   rescue => ex
      infoMsg = "Job #{bj.id} Exception #{ex.to_s}"
      out_lines.push(infoMsg)
      logger.error(infoMsg)
      status = -1
      
   ensure
      # Write a BatchHistory entry to record the job's execution
      BatchHistory.add(bj.id, startTsp, infoMsg, status)
      msg = "Job #{bj.id} Complete, status=#{status}"
      puts msg if (!emailOK)
      logger.info(msg)
      result = out_lines.to_s
   
   end
   
   if (bj.mailTo.length > 0) && emailOK
      machine = @@lcCache.getMachine
      msg = "Send job completion email to #{bj.mailTo}"
      puts msg
      logger.info(msg)
      mailer  = MailFactory.getDefaultMailer
      subj    = "Batch Job [#{machine}]: #{bj.name}"
      sentOK = mailer.sendIt(bj.mailTo, subj, result, nil)
      puts "** ERROR SENDING MAIL **" if !sentOK
   end
   
   result
   
 end


end
