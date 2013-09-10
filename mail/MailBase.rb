require          'mail'
require_relative '../cache/SystemProperties'
require_relative '../helpers/FileLogger'

class MailBase

    def initialize(service)
       @sysProps = SystemProperties.instance       
       @service  = service
       @trace    = true 
       @log      = FileLogger.new(service)
    end
    
    def sendIt ( p_recipient, p_subject, txtBody, htmBody )

        mailServer = @sysProps.getProperty(@service + "-Server", "xxx.net"  )
        mailPort   = @sysProps.getProperty(@service + "-Port"  , "587"      ).to_i
        mailUser   = @sysProps.getProperty(@service + "-Auth"  , "howiepred")
        mailPass   = @sysProps.getProperty(@service + "-Pass"  , "predhow9" )
        mailSender = @sysProps.getProperty(@service + "-From"  , "tester@raffletracker.com")
        
        mailSentOK = false 
      
        if @trace
          @log.info "Set up delivery to #{mailServer}:#{mailPort}"
        end
        
        begin       
            Mail.defaults do
            delivery_method :smtp, { :address        => mailServer,
                                     :port           => mailPort,
                                     :domain         => "noreply@raffletracker.com",
                                     :user_name      => mailUser,
                                     :password       => mailPass,
                                     :authentication => 'plain',
                                     :enable_starttls_auto => true }
            end

            txtBody += "\n\n"         if txtBody != nil
            htmBody += "<br /><br />" if htmBody != nil
     
            if @trace
              @log.info "Start delivery to #{p_recipient}"
            end
     
            mail = Mail.deliver do
              to       p_recipient
              from     mailSender
              subject  p_subject
              
              text_part do
                body txtBody
              end
             
              if htmBody != nil && htmBody.length > 0
                 html_part do
                   content_type 'text/html; charset=UTF-8'
                   body         htmBody
                 end
              end
            end  
            mailSentOK = true 

        rescue => ex
            @log.error "Error while sending mail"
            @log.error "#{ex.class} #{ex.message}"
          
        ensure
            if @trace
              @log.info "Mail delivery complete"
            end        
        end
        
        mailSentOK
        
    end

end
