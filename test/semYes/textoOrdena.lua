local palavra
local n

n = io.read("n")
local aux = io.read("l")

local palavra = {}
local i = 1
while i <= n do
	palavra[i] = io.read("l")
	i = i + 1
end

i = 2
while i <= n do
	local j = i - 1
	while j >= 1 do
		if palavra[j] > palavra[j+1] then
			local aux = palavra[j+1]
			palavra[j+1] = palavra[j]
			palavra[j] = aux
		end
		j = j - 1
	end
	i = i + 1
end

i = 1
while i <= n do
	print(palavra[i])
	i = i + 1
end

