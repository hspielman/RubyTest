require 'time'

module DateUtil

  FORMAT_FULL       = "%Y-%m-%d %H:%M:%S"
  FORMAT_SHORT      = "%Y-%m-%d %H:%M"
  FORMAT_DATE_ONLY  = "%Y-%m-%d"
  FORMAT_TIME_ONLY  = "%H:%M:%S"
  FORMAT_TIME_SHORT = "%H:%M"

  def self.format_full(time)
    time.strftime(self::FORMAT_FULL)
  end
  
  def self.format_short(time)
    time.strftime(self::FORMAT_SHORT)
  end
 
  def self.format_default(time)
    time.strftime(self::FORMAT_SHORT)
  end
  
  def self.fmt(time)
    time.strftime(self::FORMAT_SHORT)
  end 
  
  def self.format_date_only(time)
    time.strftime(self::FORMAT_DATE_ONLY)
  end
  
  
  def self.format_time_full(time)
    time.strftime(self::FORMAT_TIME_ONLY)
  end

  def self.format_time_short(time)
    time.strftime(self::FORMAT_TIME_SHORT)
  end
  
end 
