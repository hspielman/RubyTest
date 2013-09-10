require 'mail'

class SendGrid < MailBase

    def initialize(  )
      super("sendgrid")
    end
    
end
