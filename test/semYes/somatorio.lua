local x,y,z

print("digite uma sequencia de numeros ou -1 para finalizar")
z=0
y=0

while z ~= -1 do

	x = io.read("n")
	z=x
	if x ~=-1 then
		y=y+x
	end	
end

print   (" a soma eh ",y)
