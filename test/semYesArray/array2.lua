local a

local b 

a = {}

--b = novo inteiro[5][]

local i = 1

while i <= 3 do
	a[i] = i * i
	i = i + 1
end

i = 1
while i <= 3 do
	print(a[i])
	i = i + 1
end
