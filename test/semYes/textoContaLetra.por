texto linha
/*inteiro[] letra = novo inteiro[26]

inteiro i = 1
repita enquanto i <= 26
	letra[i] = 0
	i = i + 1
fim*/ 

entrada(linha)

inteiro i = 1
inteiro letra = 0
repita enquanto i <= textoComp(linha)
	texto aux = textoPos(linha, i)
	se aux >= "a" e aux <= "z"
		letra = letra + 1	
	fim
	i = i + 1
fim 

saida("Letras = ", letra)
