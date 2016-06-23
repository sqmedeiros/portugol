local s = "bola"

local n = #s

print(#s, n)

print(#"bola")

local s1 = {}

s1[1] = "a"
s1[2] = "b"
s1[3] = "escola"

local i = 1
while i <= 3 do
	print(#s1[i])
	i = i + 1
end

print(string.sub("bola", 2, 3))

print(string.sub(s1[3], 1))

s = string.sub(s1[3], 2, #s1[3])

print(s)

if string.sub(s1[3], 2, 2) == string.sub(s1[3], 2, 2) then
  print("Igual")
end

print(string.sub(s, 1, 1))
print(string.sub(s, 10, 10))
