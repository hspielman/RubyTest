#!/usr/bin/ruby

require 'mysql'

begin    
    con = Mysql.new '127.0.0.1', 'root', 'admin'
    rs = con.query "SELECT id,sku,name,price FROM fang.virtual_good;"

    p "We have #{rs.num_rows} row(s)"
    
    rs.each do |row|
        puts row.join("\s")
    end    
   
         
rescue Mysql::Error => e
    p e.errno
    p e.error
    
ensure
    con.close if con
end

print "\nHit ENTER to Exit"
gets.chomp

