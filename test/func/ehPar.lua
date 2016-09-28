function ehPar (x)
  if x % 2 == 0 then
    return true
  end
	return false
end

print("Eh par 2?", ehPar(2))
print("Eh par 33?", ehPar(33))
print("Eh par 25?", ehPar(25))
print("Eh par 48?", ehPar(48))
