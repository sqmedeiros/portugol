local x = 1
print("agora")

if x > 33 then
  x = 111
elseif x > 22 then
  if x > 11 then
  	x = 999
  end
elseif x > 11 then
  x = 888
else
  x = 22
  print("agora entendi o erro", 777)
end
