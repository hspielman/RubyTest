require 'erb' 
require 'open-uri'

# Read in the template -- no substitution performed yet
template = File.read('mail2template.txt')
puts "FROM FILE:\n" + template

url = 'http://s3.amazonaws.com/fiveurls/mail2template.txt'
template2 = nil
open(url) { |f| template2 = f.read() }
puts "FROM URL:\n" + template2

# Set values and evaluate the template in strb
amount = 2.37
map1 = { :a => 'aa1', :b => 'bb1', :firstName => 'Mary' , :amount => sprintf("$%0.2f",amount) } ;
strb = ERB.new(template).result(binding)

# Changes after the eval do not affect anything in strb
amount = 99.99
map1 = { :a => 'aa2', :b => 'bb2' , :firstName => 'Joe' , :amount => sprintf("$%0.2f",amount) } ;

puts strb 

# But they matter for a fresh eval in strc
strc = ERB.new(template).result(binding)
puts strc