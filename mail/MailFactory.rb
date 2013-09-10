require_relative '../cache/SystemProperties'

class MailFactory

  SENDGRID = "sendgrid"
  SMTP     = "smtp"

  def self.getMailer(service_name)
    if service_name == MailFactory::SMTP
      mail_service = Smtp.new
    else
      mail_service = SendGrid.new
    end
  
    mail_service  
  end
  
  def self.getDefaultMailer
    sysProps     = SystemProperties.instance       
    service_name = sysProps.getProperty("email-bulkService", "sendgrid")    
    self.getMailer(service_name)
  end

end
