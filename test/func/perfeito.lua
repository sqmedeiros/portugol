function ehPerfeito (x)
	local soma = 1
	local divisor = 2
	while divisor <= x / 2 do
		if x % divisor == 0 then
			soma = soma + divisor
		end
		divisor = divisor + 1
	end	

	return soma == x
end

print(ehPerfeito(6))
print(ehPerfeito(9))
print(ehPerfeito(28))
print(ehPerfeito(1000))
