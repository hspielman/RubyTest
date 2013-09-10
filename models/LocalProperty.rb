class LocalProperty 

 # Do NOT use FileLogger in this class or we will create a circular dependency

 @@propFile = "/RubyTest/config/local_props.txt"
 
 def self.load_all

    arr = Array.new
	idx = 0 
	
    File.open(@@propFile, 'r') do |properties_file|
      properties_file.read.each_line do |line|
        line.strip!
        if (line[0] != ?# and line[0] != ?=)
            i = line.index('=')
            if (i != nil)
              nam = line[0..i - 1].strip
              val = line[i + 1..-1].strip
              arr[idx] = LocalProperty.new(nam,val) 
              idx += 1
            end
        end
      end
    end
	
	arr
 end
 
 def initialize(name, value)
   @name   = name 
   @value  = value
 end

 attr_accessor  :name, :value
  
 def to_s  
   "name: #@name  value: #@value "
 end

 
end