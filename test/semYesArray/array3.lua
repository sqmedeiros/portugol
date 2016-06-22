local a

local b

local a = {}

local b = {}

local i = 1

while i <= 3 do
	a[i] = i * i
	i = i + 1
end

i = 1
while i <= 5 do
	b[i] = a
	i = i + 1
end

--a[2][3] = b
b[2][3] = 88

i = 1
while i <= 3 do
	print(b[2][i])
	i = i + 1
end
