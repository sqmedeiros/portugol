local b

b = {}

b[4] = {}

b[4][3] = 88

print(b[4][3])

local a

a = {}

a[8] = 99
b[3] = a

print(b[3][8])
