function fold (a, n)
	local i = 1
	local soma = 0
	while i <= n do
		soma = soma + a[i]
		i = i + 1
	end
	return soma
end

function novoArray (n)
	return {}
end

function somaArray (x, y, n)
	local i = 1
	local soma = {}
	while i <= n do
		soma[i] = x[i] + y[i]
		i = i + 1
	end
	return soma
end

function imprimeArray (x, n)
	local i = 1
	while i <= n do
		print(x[i])
		i = i + 1
	end
end


a = {}
a[1] = 1
a[2] = 3
a[3] = 100
a[4] = 5
a[5] = 10

print(fold(a, 5))

local b = novoArray(5)

b[1] = 2
print(b[1])
b[2] = 0
b[3] = 0
b[4] = 0
b[5] = 1

local c = somaArray(a, b, 5)

print("Vai imprimir 1")
imprimeArray(c, 5)

print("Vai imprimir 2")
imprimeArray(somaArray(a, b, 5), 5)

