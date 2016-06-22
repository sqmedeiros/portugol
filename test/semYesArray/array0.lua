local a = {}
local b
local x = 10
local y
y = {}

b = a[1]
print("tudo bem", b)
a[1] = 56
b = a[1]
print("tudo bem2", b)
a[2] = 57
print("tudo bem2", a[2])

