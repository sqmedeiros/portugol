texto[] palavra
inteiro n

entrada(n)
texto aux
entrada(aux)

palavra = novo texto[n]
inteiro i = 1
repita enquanto i <= n
	entrada(palavra[i])
	i = i + 1
fim

i = 2
repita enquanto i <= n
	inteiro j = i - 1
	repita enquanto j >= 1
		se palavra[j] > palavra[j+1]
			texto aux = palavra[j+1]
			palavra[j+1] = palavra[j]
			palavra[j] = aux
		fim
		j = j - 1
	fim
	i = i + 1
fim

i = 1
repita enquanto i <= n
	saida(palavra[i])
	i = i + 1
fim

