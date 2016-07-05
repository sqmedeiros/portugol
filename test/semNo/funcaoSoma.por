funcao soma1 (inteiro a, inteiro b) retorna inteiro[][]
	retorne novo inteiro[10][10]
	inteiro[][] x
	retorne x
	retorne x[1]  //Erro: tipo de retorno incompatível
	retorne novo texto[5][5] //Erro: tipo de retorno incompatível
fim

funcao soma2 (inteiro a, inteiro b) retorna inteiro[]
	inteiro[][] x
	retorne novo inteiro[10]
	retorne x[10] 
	retorne // Erro: tipo de retorno vazio
fim

funcao soma3 (inteiro a, inteiro b) retorna inteiro
	retorne a + b
fim

funcao soma4 ()
	retorne a + b //Erro: 'a' e 'b' não declarados (3 erros)
	texto t
	retorne t  //Erro: função não retorna valores
fim

inteiro a = 2
inteiro b
inteiro[] c
texto t

a = soma1(3, 4) //Erro
a = soma2(3, 4) //Erro
b = soma3(3, 4) //Ok
t = soma3(3, 4) //Erro
a = soma3(3)    //Erro
a = soma3()     //Erro
a = soma3(3.0, 4.0)  //Erro
a = soma4(3, 4) //Erro

c = soma2(a, b) //Ok
