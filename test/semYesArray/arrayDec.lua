local a = {}

local b

local c = a

b = a

a[1] = 10
print(a[1], b[1], c[1])

a = {}
a[3] = 44
print(a[1], b[1], c[1])
print(a[3], b[3], c[3])
