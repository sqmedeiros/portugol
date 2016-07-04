inteiro[] a

inteiro[][] b

a = novo inteiro[3]

b = novo inteiro[5][]

inteiro i = 1

repita enquanto i <= 3
	a[i] = i * i
	i = i + 1
fim

i = 1
repita enquanto i <= 5
	b[i] = a
	i = i + 1
fim

//a[2][3] = b
b[3][4] = 88

i = 1
repita enquanto i <= 3
	escreva(b[2][i])
	i = i + 1
fim
