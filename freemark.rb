
# Read in the template -- no substitution performed yet
stra = File.read('mailtemplate.txt')
puts stra

# Set values and evaluate the template in strb
amount = 2.37
map1 = { :a => 'aa1', :b => 'bb1', :firstName => 'Mary' , :amount => sprintf("$%0.2f",amount) } ;
strb = eval('"' + stra + '"' )

# Changes after the eval do not affect anything in strb
amount = 99.99
map1 = { :a => 'aa2', :b => 'bb2' , :firstName => 'Joe' , :amount => sprintf("$%0.2f",amount) } ;

puts strb 

# But they matter for a fresh eval in strc
strc = eval('"' + stra + '"' )
puts strc