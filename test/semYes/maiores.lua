local x, y, z = 3.0, 8.0

print("Digite o valor de z: ")
z = io.read("n")

if x > z and y > z then
  print("x e y sao maiores que z")
elseif y > z then
  print("y eh maior que z")
else
  print("z nao eh menor que x e y")
end



