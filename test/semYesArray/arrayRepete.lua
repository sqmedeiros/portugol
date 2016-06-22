local a = {}

a[1] = 1
a[2] = 4
a[3] = -5
a[4] = 15
a[5] = 4

local repete = false
local i = 1
while i <= 5 do
	local j = i + 1
	while j <= 5 do
		if a[i] == a[j] then
			repete = true
		end
		j = j + 1
	end
	i = i + 1
end

if repete then
	print("Array possui elementos repetidos")
else
	print("Array nao possui elementos repetidos")
end
