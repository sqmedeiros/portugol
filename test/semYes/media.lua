--Calcula média entre dois números
--Programa funciona corretamente com Lua 5.3 instalado
--Lua 5.3 tem o tipo inteiro, o que torna trivial a implementação do interpretador
--Lua 5.2 não tem tipo inteiro

local a, b,c, m

print("Digite a idade das duas pessoas: ")
a = io.read("n")
b = io.read("n")
c=a+b
m= c//2
print("A media eh: ",m)

c=(a+b)//2

print("A media eh: ",m)
