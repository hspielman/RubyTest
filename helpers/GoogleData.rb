require_relative "./Parse"
require_relative "./FileLogger"
require_relative "../models/DBReport"

class GoogleData
   
  def initialize(params)
    @rptID = Parse.get_int(params[:rptID] , 0)
    @usrID = Parse.get_int(params[:userID], 0)
    @orgID = Parse.get_int(params[:orgID] , 0)
    
    @col_types = Array.new
    @spec_map  = { :userID => @usrID, :orgID => @orgID }
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
  
  # https://developers.google.com/chart/interactive/docs/reference#dataparam
  
  # {version:'0.6',status:'ok',
  #  table:{cols:[{id:'Col1',label:'',type:'number'}],
  #         rows:[{c:[{v:1.0,f:'1'}]},
  #               {c:[{v:2.0,f:'2'}]},
  #               {c:[{v:3.0,f:'3'}]},
  #               {c:[{v:1.0,f:'1'}]} ] }
  # }
    
  # COLUMN Types
  #  Tiny Int Boolean = 1
  #  Small Int        = 3
  #  Big Integer      = 8
  #  Decimal          = 246
  #  Timestamp        = 7
  #  String VARCHAR   = 253
  #  String CHAR      = 254
  
  def col_info(rs)
    sep  = ""
    seq  = 1 
    colJS = "cols:["
    rs.fetch_fields.each do |info|
      ctype = 'string'     # 253, 254
      ctype = 'number'  if (info.type == 8 || info.type == 3 || info.type == 1 || info.type == 246)
      ctype = 'date'    if (info.type == 7)
      colJS += "#{sep}{id:'col#{seq}',label:'#{info.name}',type:'#{ctype}'}"
      
      @col_types.push((info.type == 246) ? 'float' : ctype)
      sep = ","
      seq += 1
    end
    colJS += "]"
    colJS
  end
  
  def format_col(col, idx)
     col_type = @col_types[idx]
     return  "#{col.to_f}" if col_type == 'float'
     return  "#{col.to_i}" if col_type == 'number'
     return  "new Date(2013,1,1, 23,59,59)" if col_type == 'date'
     return  "'#{col.to_s}'"
  end
  
  def col_values(row)
    cVals = ""
    rsep  = "" 
    idx   = 0
    row.each do |col|
      cVals += "#{rsep}{v: #{format_col(col, idx)}}"
      rsep = ","
      idx += 1
    end
	 cVals
  end
  
  def row_info(rs)
    sep   = ""
    rowJS = "rows:["
    rs.each do |row|
      rowJS += "#{sep}{ c:[#{col_values(row)}] }"
      sep = ","
    end
    rowJS += "]"
    rowJS
  end

  
  def table_result(rs)
    return error_result('invalid_request') if rs.nil?
    resp = "{version:'0.6',status:'ok',"
    resp +=  "table:{" + col_info(rs) + "," + row_info(rs) + "}" 
    resp += "}"
  end
  
  def execute
    # Read the DBReport by its unique ID
    dbr = DBReport.get_by_id(@rptID)
	 jsResp = error_result('invalid_request') 
    return jsResp if dbr.nil?
    
    # Apply the params to the report and run it 
    dbr.parse_statement
    dbr.set_spec_map(@spec_map)
    sql_stmt = dbr.executable_statement(@user_parms) 
    if ( sql_stmt.size > 0 )
      rs = DBUtil.exec_query("exec-google-data", sql_stmt)    
      if ( ! rs.nil? )
      
        # rs.fetch_fields.each_with_index do |info, i|
        #   printf "- Column %d (%s) -\n"  , i, info.name      # Native column name or label from as 'XXX' 
        #   printf " table:            %s\n", info.table
        #   printf " def:              %s\n", info.def
        #   printf " type:             %s\n", info.type         # see above
        #   printf " length:           %s\n", info.length
        #   printf " max_length:       %s\n", info.max_length
        #   printf " flags:            %s\n", info.flags
        #   printf " decimals:         %s\n", info.decimals
        # end
      
        jsResp = table_result(rs)

      end
    end
    
    jsResp
  end
  
end
