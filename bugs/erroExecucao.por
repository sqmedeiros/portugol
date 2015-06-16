inteiro a = 33

saida("valor de a = ", a)

texto t = "bola"
saida("novo" + " texto")
saida("nova " + t)


repita enquanto a > 0
	saida("Digite o novo valor de a: ")
	entrada(a)
	saida("novo valor de a = ", a)

	se a mod 2 == 0
  	saida("'a' eh par")
	senaose a mod 3 == 0 e a > 10
		saida("'a' eh impar e divisivel por 3 e maior que 10")
	senaose a mod 5 == 0 ou a mod 7 == 0
		saida("'a' eh divisivel por 5 ou 7")
	senao
		saida("'a' eh impar e vale ", a)
	fim
fim

