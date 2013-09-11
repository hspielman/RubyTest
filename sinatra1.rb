require 'sinatra'
require 'erb'

require_relative './cache/LocalProperties'
require_relative './cache/TimedCache'
require_relative './cache/SystemProperties'
require_relative './cache/AppKeys'
require_relative './cache/USStates'
require_relative './cache/CacheInit'

require_relative './helpers/Parse'
require_relative './helpers/FileLogger'
require_relative './helpers/DBUtil'
require_relative './helpers/DateUtil'
require_relative './helpers/Template'
require_relative './helpers/GoogleData'

include ERB::Util

Dir["./models/*.rb"].each { |file| require_relative file }
Dir["./mail/*.rb"].each   { |file| require_relative file }
Dir["./batch/*.rb"].each  { |file| require_relative file }
Dir["./svc/*.rb"].each    { |file| require_relative file }

# See : http://www.sinatrarb.com/configuration.html 
#       http://www.sinatrarb.com/contrib/


# directory for json / xml web services is /svc, not /views
ws_opts = { :content_type => "text/json", :views => "svc" }

# Allow use of line-break suppression in ERB templates
set :erb, :trim => '-'

# Count all requests recieved
@@rq_count = 0

runBatch = false 
ARGV.each do |arg|
  parm = arg.downcase
  if parm == "-batch"
    runBatch = true 
  end
end

if runBatch
  Batch.start 
else
  puts " ** Batch Scheduler is DISABLED. Add -batch to run it ** "
end

before do
  @@rq_count += 1 
end
  
not_found do
  localVars = { :msg => "The page you requested at '#{request.path}' was not found" }
  fname = "index"
  filename = "views/#{fname}.erb"  
  if File.exists?(filename)
    erb fname.to_sym, :locals => localVars
  else
    p "Page not found (and no index.htm either)"
  end
end
  
# Either /json or /svc in path indicates JSON web service  
[ '/json/:name/*', '/svc/:name/*' ].each do |route|
   get route do
     fname = 'json/' + params[:name]
     filename = "svc/" + fname + ".erb"  
     if File.exists?(filename)
       erb fname.to_sym,ws_opts
     else
       p "Service " + filename + " not found"
     end  
   end
end
 
# Translate '.htm' files to /views/*.erb templates 
get '/*.htm' do
  fname = params[:splat].first
  filename = "views/" + fname + ".erb"  
  if File.exists?(filename)
    erb fname.to_sym
  else
    p "File " + filename + " not found"
  end
end
  
get '/CacheInit' do
  CacheInit.reload_all
end
   
get '/GoogleData' do
  goog = GoogleData.new(params)
  goog.execute
end
	
# Mini methods dispatched locally  
get '/foo' do
  "hey, FOO!"
end

get '/test000' do
  erb 'test0'.to_sym
end

get '/hello/:name' do
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params[:name] is 'foo' or 'bar'
  code = "Hello #{params[:name]}!  - the time is <%= Time.now %>"
  erb code
end

# Index page is also an ERB view
get '/' do
  fname = "index"
  filename = "views/#{fname}.erb"  
  if File.exists?(filename)
    erb fname.to_sym
  else
    p "File " + filename + " not found"
  end

end

