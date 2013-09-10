require 'erb' 
require 'open-uri'

# See also:  http://www.stuartellis.eu/articles/erb/
#            http://stackoverflow.com/questions/2321428/evaluating-string-templates
#            http://freecode.com/articles/templates-in-ruby

class Template

   # No template set yet...
   def initialize()
     @template = "call load_file() or load_url() to load a template"
   end
  
   # Load the template from a file
   def load_file(file_name)
      ok = true
      begin
        @template = File.read(file_name)
      rescue => ex
        @template = ex.to_s 
        ok = false
      end
      return ok
   end
   
   # Load the template from an URL
   def load_url(url)
      ok = true
      begin
       open(url) { |f| @template = f.read() }
      rescue => ex
        @template = ex.to_s 
        ok = false
      end
      return ok
   end
   
   # Return the template -- NOT EVALUATED
   def template
     @template
   end
   
   # Return template with substitutions, as evaluated by tmap (hash)
   def evaluate(tmap)
     begin
       tsub = ERB.new(@template).result(binding)
     rescue => ex
       tsub = ex.to_s
     end
     return tsub
   end
  
end 
