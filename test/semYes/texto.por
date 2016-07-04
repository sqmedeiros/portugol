texto s = "bola"

inteiro n = textoComp(s)

escreva(textoComp(s), n)

escreva(textoComp("bola"))

texto[] s1 = novo texto[3]

s1[1] = "a"
s1[2] = "b"
s1[3] = "escola"

inteiro i = 1
repita enquanto i <= 3
	escreva(textoComp(s1[i]))
	i = i + 1
fim

escreva(textoSub("bola", 2, 3))

escreva(textoSub(s1[3], 1))

s = textoSub(s1[3], 2, textoComp(s1[3]))

escreva(s)

se textoPos(s1[3], 2) == textoSub(s1[3], 2, 2)
  escreva("Igual")
fim

escreva(textoPos(s, 1))
escreva(textoPos(s, 10))
