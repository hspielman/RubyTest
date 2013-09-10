
seq = 1
reps = 50
clrStart = 16
while seq <= reps do
  clrEnd = clrStart + 50
  puts "<linearGradient id='gradRank#{seq}' x1='0%' y1='0%' x2='0%' y2='100%'>"
  puts "<stop offset='5%'  stop-color='rgb(#{clrStart},#{clrStart},#{clrStart})' />"
  puts "<stop offset='95%' stop-color='rgb(#{clrEnd},#{clrEnd},#{clrEnd})' />"
  puts "</linearGradient>"       
  seq += 1
  clrStart += 3
end
