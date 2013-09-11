require_relative "./Parse"
require_relative "./FileLogger"
require_relative "../models/DBReport"

class GoogleData
   
  def initialize(params)
    @rptID = Parse.get_int(params[:rptID] , 0)
    @usrID = Parse.get_int(params[:userID], 0)
    @orgID = Parse.get_int(params[:orgID] , 0)
	 
	 @spec_map = { :userID => @usrID, :orgID => @orgID }
    @user_parms = Array.new
    seq = 1
    while true do
      pname = "p#{seq}"
      p = params[pname.to_sym]
      break if p.nil?
      @user_parms.push(p)
		seq += 1
    end
  end

  def error_result(reason_str)
    "{status:'error',errors[{reason:'#{reason_str}'}]}"
  end
  
  # {version:'0.6',status:'ok',
  #  table:{cols:[{id:'Col1',label:'',type:'number'}],
  #         rows:[{c:[{v:1.0,f:'1'}]},
  #               {c:[{v:2.0,f:'2'}]},
  #               {c:[{v:3.0,f:'3'}]},
  #               {c:[{v:1.0,f:'1'}]} ] }
  # }
    
  # COLUMN Types
  #  Integer = 8
  #  Decimal = 246
  #  String  = 253
  #  Boolean = 8
  #  Timestamp = 12
  
  def table_result(cols, rows)
    resp = "{version:'0.6',status:'ok',"
	 resp +=  "table:{cols:[], rows:[]}" 
	 resp += "}"
  end
  
  def execute
    # Read the DBReport by its unique ID
    dbr = DBReport.get_by_id(@rptID)
	 if dbr.nil?
	   return error_result('invalid_request')
	 end
    
    # Apply the params to the report and run it 
    dbr.parse_statement
    parm_arr = dbr.parm_arr
    dbr.set_spec_map(@spec_map)
	 sql_stmt = dbr.executable_statement(@user_parms) 
	 jsResp = "" 
	 if ( sql_stmt.size > 0 )
	   rs = DBUtil.exec_query("exec-google-data", sql_stmt)    
	   if ( ! rs.nil? )
		
		  rs.fetch_fields.each_with_index do |info, i|
			  printf "- Column %d (%s) -\n"  , i, info.name      # Native column name or label from as 'XXX' 
			  printf " table:            %s\n", info.table
			  printf " def:              %s\n", info.def
			  printf " type:             %s\n", info.type         # see above
			  printf " length:           %s\n", info.length
			  printf " max_length:       %s\n", info.max_length
			  printf " flags:            %s\n", info.flags
			  printf " decimals:         %s\n", info.decimals
		  end
		
        rs.each do |row|
		    # Build json response
			 # puts  row.to_s
        end
	   else
        # NO RESULTS RETURNED
	   end
    end
	 
	 jsResp
  end
  
end
