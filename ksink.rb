require 'mysql'

# show the Class of some stuff
p 1.class
p 1.5.class
p "hello".class
false.class
nil.class

# Show command line args
nargs = ARGV.length
0.upto(nargs-1) do |n|
  p "ARG[#{n}] = #{ARGV[n]}"
end

ACONST = 22

# A Gloabal variable starts with $
$fnCalls = 0 

# One way to loop
3.times { print "a" }
p("")

#Another way to loop
1.upto(10) { |x| print x }
p("")

# Sort an array (modify it)
a = [1,3,9,6,2]
p a
a.sort!
p a
for val in a do
  print " #{val+1} "
end
p("")

a.each { |z| print " " + (z+3).to_s + " " }
p("")

# define a function
def square(q)
  $fnCalls += 1
  q*q
end

def mult(a,b)
  $fnCalls += 1
  a*b
end
  
def even?(x)
  $fnCalls += 1
  x % 2 == 0
end

# Map array values to another array  
b = a.map { |x| square(x) }
p b

# Build a hash from array
c = {}
a.each do |x|
 print ( " #{even?(x)} " )
 c[x.to_s.to_sym] = x*Math::PI
end
p("\n")
p c
p("")

s = "verify"
s[s.length-1] = 'x'
0.upto(s.length-1) { |n|
  print "#{s[n]} "
}
p("")

=begin
  We can have
  several lines of
  comments in here
=end

p "Executing " + __FILE__ + " at line " + __LINE__.to_s

p ACONST**3

# Show value of global
p "We made #{$fnCalls} function calls"

# Read a SQL Table
begin    
    con = Mysql.new '127.0.0.1', 'root', 'admin'
    rs = con.query "SELECT id,sku,name,price FROM fang.virtual_good;"

    p "Table has #{rs.num_rows} row(s)"
    
    rs.each do |row|
        puts row.join("\s")
    end    
   
         
rescue Mysql::Error => e
    p e.errno
    p e.error
    
ensure
    con.close if con
end


# All done
print "\nHit ENTER to Exit"
gets.chomp
