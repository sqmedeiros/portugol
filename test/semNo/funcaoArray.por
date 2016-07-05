funcao soma1 (inteiro[] a, numero[][] b) retorna inteiro[][]
	texto a //Erro: redeclaracao de variavel
	retorne novo inteiro[5][5]
	retorne novo numero[5][5] //Erro
	retorne soma1(a, b)
fim

inteiro[][] x = soma1(novo inteiro[3], novo inteiro[3][4])
inteiro[][] y = soma1(novo inteiro[3], novo inteiro[3]) // Erro
inteiro[] z = soma1(novo inteiro[3], novo inteiro[3][4]) //Erro


