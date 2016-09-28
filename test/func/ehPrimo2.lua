function ehPrimo (x)
  local i = 2

  while i < x do
    if x % i == 0 then
      return false
    end
    i = i + 1
  end
	
  return true
end

print("Eh primo 2?", ehPrimo(2))
print("Eh primo 3?", ehPrimo(3))
print("Eh primo 4?", ehPrimo(4))
print("Eh primo 5?", ehPrimo(5))
print("Eh primo 6?", ehPrimo(6))
print("Eh primo 16?", ehPrimo(16))
