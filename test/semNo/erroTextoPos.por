texto s1 = "bola"
texto s2 = "casa"

texto[] s3 = novo texto[10]

//Erro: primeiro parâmetro do tipo inteiro
inteiro b = textoPos(3, 4)

//Erro: segundo parâmetro do tipo numero
b = textoPos(s1, 3.4)

//Erro: mais parâmetros do que o esperado
b = textoPos(s1, 1, 2)

//Erro: menos parâmetros do que o esperado
b = textoPos(s1)

//Erro: menos parâmetros do que o esperado
b = textoPos()

//Erro: textSub retorna uma cadeia de caracteres
b = textoPos(s1, 1)

s3[1] = textoPos(s1, 1)

s1 = textoPos(s3[2], 1)

