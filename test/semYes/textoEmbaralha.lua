local s1, s2

print("Digite uma palava: ")
s1 = io.read("l")
print("Digite outra palavra: ")
s2 = io.read("l")

local s3 = ""

local i = 1
while i <= #s1 and i <= #s2 do
	s3 = s3 .. string.sub(s1, i, i) .. string.sub(s2, i, i)
	i = i + 1
end

while i <= #s1 do
	s3 = s3 .. strinng.sub(s1, i, i)
	i = i + 1
end

while i <= #s2 do
	s3 = s3 .. string.sub(s2, i, i)
	i = i + 1
end

print(s1, s2, s3)
