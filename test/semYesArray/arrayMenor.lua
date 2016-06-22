local a
local tam

print("Digite o numero de elementos do array: ")
tam = io.read("n")
a = {}

local i = 1
while i <= tam do
	print("Digite o elemento ", i, ": ")
	a[i] = io.read("n")
	i = i + 1
end

local menor = a[1]
i = 2
while i <= tam do
	if a[i] < menor then
    menor = a[i]
  end	
  i = i + 1
end

print("Menor = ", menor)
