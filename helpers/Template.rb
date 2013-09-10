require 'erb' 
require 'open-uri'

# See also:  http://www.stuartellis.eu/articles/erb/
#            http://stackoverflow.com/questions/2321428/evaluating-string-templates
#            http://freecode.com/articles/templates-in-ruby

class Template

   # No template set yet...
   def initialize()
     @template = "call load_file() or load_url() to load a template"
	  @loadOK   = false 
   end
  
   # Load from any source
	def load_from(source)
	  if ( source[0..4] == 'http:' || source[0..5] == 'https:' )
	    load_url(source)
	  else
	    load_file(source)
	  end
	end
	
   # Load the template from a file
   def load_file(file_name)
	     @loadOK   = false 
      begin
        @template = File.read(file_name)
	     @loadOK   = true 
      rescue => ex
        @template = ex.to_s 
	     @loadOK   = false 
      end
      return @loadOK
   end
   
   # Load the template from an URL
   def load_url(url)
	     @loadOK   = false 
      begin
        open(url) { |f| @template = f.read() }
	     @loadOK   = true 
      rescue => ex
        @template = ex.to_s 
	     @loadOK   = false 
      end
      return @loadOK
   end
   
   # Return the template -- NOT EVALUATED
   def template
	  raise "Template was not loaded: #{@template}" if !@loadOK
     @template
   end
   
   # Return template with substitutions, as evaluated by tmap (hash)
   def evaluate(tmap)
	  raise "Template was not loaded: #{@template}" if !@loadOK
	  
	  @tmap = tmap
     tsub  = ERB.new(@template).result(binding)   
     tsub
   end
  
end 
