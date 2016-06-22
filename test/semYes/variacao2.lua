local  a,n
print("Digite n")
n = io.read("n")
a=n
while a>=1 do
  print(a)
  a=a-1
end

local b
b=1
while b < n do
  if b % 2 == 0 then
    print( b, " eh par")

  end
  b = b + 1
end


local d,g,f
d=1
g=1
while d <= 10 do 

	 g=1
  print("Tabuada do ",d)

	while g<=10 do

		 f=d*g
		 print(f)
		g=g+1
	end
	d=d+1
end
