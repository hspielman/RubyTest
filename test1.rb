require "rubygems"
require "json"
require_relative "circl"

print "What is your name? "
name = gets.chomp

regexD = /\d/ 
resp = regexD.match(name[0]) ? "Ha Ha - your name is a number" : "Hello"

alist = [2,4,6,5,3,1,0]
p alist
alist.sort!
p alist

puts "#{resp} #{name}!"

jstr  ='{"desc":{"someKey":"someValue","anotherKey":"value"},"main_item":{"stats":{"a":8,"b":12,"c":10}}}'
p jstr 

phash = JSON.parse(jstr)   # returns a hash

p phash["desc"]["someKey"]
p phash["main_item"]["stats"]["a"]

phash.each { |k,v| p "JSON k,v #{k} => #{v}" }

phash["main_item"]["stats"].each do |k,v|
  p "stats: #{k} = #{v}"
end

mash = { :one => 'z', :three => 'a', :fiddy => 'r' }
p mash

def square(x)
  x*x
end

p square(8)

p Math::PI * Math::PI

c1 =  Circl.new(1) 
c2 =  Circl.new(2)
c3 =  Circl.new(Math::PI)
circles = [c1, c2, c3]

circles.each { |c| p "cX r=#{c.radius} d=#{c.diameter} c=#{c.circumference} a=#{c.area} " }

p `dir`


print "\nHit ENTER to Exit"
gets.chomp
