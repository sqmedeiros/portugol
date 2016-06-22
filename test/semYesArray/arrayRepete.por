inteiro[] a = novo inteiro[5]

a[1] = 1
a[2] = 4
a[3] = -5
a[4] = 15
a[5] = 4

bool repete = falso
inteiro i = 1
repita enquanto i <= 5
	inteiro j = i + 1
	repita enquanto j <= 5
		se a[i] == a[j]
			repete = verdadeiro
		fim
		j = j + 1
	fim
	i = i + 1
fim

se repete
	saida("Array possui elementos repetidos")
senao
	saida("Array nao possui elementos repetidos")
fim
