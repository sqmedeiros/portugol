function soma (a, b) 
	return a + b
end

function somaTexto (a, b)
	return a .. b
end

print(soma(3, 4))
print(somaTexto("deu ", "certo"))

local a = 44
local b = 55
print(soma(a, b))

function fatorial (n)
	if n == 0 then
		return 1
	else
		return n * fatorial(n-1)
	end
end

print(fatorial(5))
