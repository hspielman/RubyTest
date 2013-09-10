class Circl 

 def initialize(r)
   @rad = r
 end

 def radius
   return @rad 
 end
   
 def diameter  
   return @rad * 2
 end
 
 def circumference
   return Math::PI * @rad * 2
 end
 
 def  area
   return Math::PI * @rad * @rad
 end
 
end
