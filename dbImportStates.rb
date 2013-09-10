require_relative './cache/LocalProperties'
require_relative './cache/AppKeys'
require 'open-uri'
require 'json'

yy = 0
ARGV.each do |arg| 
  parm = arg.downcase
  if parm[0..2] == '-y:'
    yy = Parse.get_int( parm[3..-1], 2012)
    puts "Get data for #{yy}"
  else
    puts "Unknown arg #{parm}"
  end
end

INSERT_STATE   = "INSERT INTO state (id,name) VALUES (?,?) ; " 
 
DELETE_SCRATCH = "DELETE from state_census_scratch " ;

INSERT_CENSUS_SCRATCH = "INSERT INTO state_census_scratch " + 
                " (year,stateID,population,populationRank) " +
                " VALUES (?,?,?,?) ; " 
        
INSERT_CENSUS = "INSERT INTO state_census ( year,stateID,population,populationRank ) " +
      " SELECT  year,stateID,population, @seq := @seq + 1  " +
      " FROM state_census_scratch scr, (select @seq := 0) initCount " +  
      " WHERE scr.year = ? ORDER BY scr.population DESC " ;
        
akCache = AppKeys.instance       
appKey  = akCache.getKey('data.gov', nil) 

stateURL = "http://api.data.gov/census/american-community-survey/v1/#{yy}/populations/states?api_key=#{appKey}" 
puts  "API URL = #{stateURL}" 

contents = "{}"
begin
  open(stateURL) { |f| contents = f.read() }
rescue => ex
  contents = "Exception " + ex.to_s 
end

jp = JSON.parse(contents)

if ( yy > 0 )
   # Delete old scratch values
   DBUtil.update_object("DeleteScratch", false, DELETE_SCRATCH )   
   jp.each do |st| 
      puts "#{st}"
      # Insert values into scratch table
      DBUtil.update_object("InsertScratch", false, INSERT_CENSUS_SCRATCH, yy, st[2], st[0], 0)   
   end
   # Copy from scratch to real table, assigning population ranks
   DBUtil.update_object("InsertCensus", false, INSERT_CENSUS, yy )   
else
   puts "INSERT into state_census VALUES (#{st[2]},'#{st[1]}', 'xx', 0,0,'UTC-05:00',true); " 
   # DBUtil.update_object("State", false, INSERT_STATE,  st[2], st[1])  
end
