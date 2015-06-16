inteiro  a,n
saida("Digite n")
entrada(n)
a=n
repita enquanto a>=1
  saida(a)
  a=a-1
fim	

inteiro b
b=1
repita enquanto b < n
  se b mod 2 == 0
    saida( b, " eh par")

  fim
  b = b + 1
fim


inteiro d,g,f
d=1
g=1
repita enquanto d <= 10   

	 g=1
  saida("Tabuada do ",d)

	repita enquanto g<=10 

		 f=d*g
		 saida(f)
		g=g+1
	fim
	d=d+1
fim
