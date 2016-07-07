funcao fold (inteiro[] a, inteiro n) retorna inteiro
	inteiro i = 1
	inteiro soma = 0
	repita enquanto i <= n
		soma = soma + a[i]
		i = i + 1
	fim
	retorne soma
fim

funcao novoArray (inteiro n) retorna inteiro[]
	retorne novo inteiro[n]
fim

funcao somaArray (inteiro[] x, inteiro[] y, inteiro n) retorna inteiro[]
	inteiro i = 1
	inteiro[] soma = novo inteiro[n]
	repita enquanto i <= n
		soma[i] = x[i] + y[i]
		i = i + 1
	fim
	retorne soma
fim



inteiro[] a = novo inteiro[5]
a[1] = 1
a[2] = 3
a[3] = 100
a[4] = 5
a[5] = 10

escreva(fold(a, 5))

inteiro[] b = novoArray(5)

b[1] = 2
escreva(b[1])
b[2] = 0
b[3] = 0
b[4] = 0
b[5] = 1

inteiro[] c = somaArray(a, b, 5)

inteiro i = 1
repita enquanto i <= 5
	escreva(c[i])
	i = i + 1
fim
