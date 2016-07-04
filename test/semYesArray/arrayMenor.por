inteiro[] a
inteiro tam

escreva("Digite o numero de elementos do array: ")
leia(tam)
a = novo inteiro[tam]

inteiro i = 1
repita enquanto i <= tam
	escreva("Digite o elemento ", i, ": ")
	leia(a[i])
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

escreva("Menor = ", menor)
