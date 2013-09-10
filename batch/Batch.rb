require_relative '../cache/LocalProperties'
require_relative '../cache/SystemProperties'
require_relative '../models/BatchJob'

class Batch

@@shortSleep = 120     # 120
@@longSleep  = 300     # 300
@@errorSleep = 899

@@active    = false
@@executor  = false
@@sleepSecs = @@shortSleep / 2
@@lcCache   = LocalProperties.instance
@@syCache   = SystemProperties.instance
@@wakeCount = 0

@@log = FileLogger.new("Batch")

def Batch.schedule_next

   # Only schedule work if we are the Executor machine
   now = Time.new
   logIt = ((@@wakeCount%10) == 1)
   msg   = "Batch Executor: #{@@executor}"
   
   if @@executor
      @@active = true 
      
      # Check DB to see if there is a job now ready to run.
      # For each one we find, execute the batch job.
      jobList = BatchJob.list_ready  
      msg = "Jobs ready to run: "
      if jobList.length == 0 
        msg += "NONE" 
      else
        puts " * Batch is Executor at #{now.to_s}, wake=#{@@wakeCount}" 
        jobList.each do |job| 
           puts " * Batch Job #{job.id}, #{job.name}, #{job.command}" 
           bjExec = BatchJobExec.new
           bjExec.execute(job)
        end
        logIt = true
      end
      
      @@active = false
   end  
   
   @@log.info(msg) if logIt
   
   return @@executor
end

def Batch.start
   this_machine = @@lcCache.getProperty("machine" , "local")
   puts "Batch scheduler starting on machine [#{this_machine}]"
   Thread.new do
      loop do
         begin
            now = Time.new
            if ( @@wakeCount%10 == 0 )
              puts "Batch scheduler sleep for #{@@sleepSecs} seconds, at #{now.to_s}, executor=#{@@executor}"
            end
            sleep(@@sleepSecs)
            @@wakeCount += 1
            
            exec_machine = @@syCache.getProperty("batch-Executor", "none" )
            @@executor   = (this_machine == exec_machine)            
            Batch.schedule_next           
            @@sleepSecs  = @@executor ? @@shortSleep : @@longSleep 
         rescue => ex
            msg = "Exception " + ex.to_s
            puts msg
            @@log.error(msg) 
            @@sleepSecs  = @@errorSleep 
         ensure
            # Nothing right now...
         end
      end
   end
end


def Batch.executor?
  @@executor
end

def Batch.sleep_seconds
  @@sleepSecs
end

end
