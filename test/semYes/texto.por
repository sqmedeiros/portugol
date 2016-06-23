texto s = "bola"

inteiro n = textoComp(s)

saida(textoComp(s), n)

saida(textoComp("bola"))

texto[] s1 = novo texto[3]

s1[1] = "a"
s1[2] = "b"
s1[3] = "escola"

inteiro i = 1
repita enquanto i <= 3
	saida(textoComp(s1[i]))
	i = i + 1
fim

saida(textoSub("bola", 2, 3))

saida(textoSub(s1[3], 1))

s = textoSub(s1[3], 2, textoComp(s1[3]))

saida(s)

se textoPos(s1[3], 2) == textoSub(s1[3], 2, 2)
  saida("Igual")
fim

saida(textoPos(s, 1))
saida(textoPos(s, 10))
