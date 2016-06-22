inteiro[] a
inteiro tam

saida("Digite o numero de elementos do array: ")
entrada(tam)
a = novo inteiro[tam]

inteiro i = 1
repita enquanto i <= tam
	saida("Digite o elemento ", i, ": ")
	entrada(a[i])
	i = i + 1
fim

inteiro menor = a[1]
i = 2
repita enquanto i <= tam
	se a[i] < menor
    menor = a[i]
  fim	
  i = i + 1
fim

saida("Menor = ", menor)
