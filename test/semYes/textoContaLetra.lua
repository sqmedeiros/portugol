local linha = io.read("l")

local i = 1
local letra = 0
while i <= #linha do
	local aux = string.sub(linha, i, i)
	if aux >= "a" and aux <= "z" then
		letra = letra + 1	
	end
	i = i + 1
end

print("Letras = ", letra)
