local a = 1
local b = 3.4
local c1, c2 = false, true
local t = "alex"

while a > 0 do
	print("Digite o novo valor de a: ")
	a = io.read("n")
  if a % 2 ~= 0 and not (a % 5 == 0) then 
    print(a, " nao eh par nem eh divisivel por 5")
  elseif a % 3 == 0 then
    print(a, " eh divisivel por 3")
  elseif a % 2 == 0 then
    print(a, " eh par")
	else
    print(a, " eh impar")
  end
end

