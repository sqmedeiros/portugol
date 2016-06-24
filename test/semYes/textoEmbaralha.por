texto s1, s2

saida("Digite uma palava: ")
entrada(s1)
saida("Digite outra palavra: ")
entrada(s2)

texto s3 = ""

inteiro i = 1
repita enquanto i <= textoComp(s1)  e  i <= textoComp(s2)
	s3 = s3 + textoPos(s1, i) + textoPos(s2, i)
	i = i + 1
fim

repita enquanto i <= textoComp(s1)
	s3 = s3 + textoPos(s1, i)
	i = i + 1
fim

repita enquanto i <= textoComp(s2)
	s3 = s3 + textoPos(s2, i)
	i = i + 1
fim

saida(s1, s2, s3)
