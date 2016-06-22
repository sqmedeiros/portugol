local a

local tam

print("Tamanho do array: ")
tam = io.read("n")
a = {}
print("Digite os elementos do array")

local i = 1
while i <= tam do
	a[i] = io.read("n")
	i = i + 1
end

i = 1
while i <= tam do
	print(a[i])
	i = i + 1
end
