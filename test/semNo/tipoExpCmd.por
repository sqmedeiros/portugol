inteiro a = 1

se 0
	a = 2
senaose 1
	a = 3
senaose 1.0
	a = 4
senaose "verdadeiro"
	a = 5
senaose verdadeiro
	a = 6
senaose falso
	a = 7
fim

repita enquanto 1
	a = a + 1
fim

repita enquanto 1.0
	a = a + 1
fim

texto t 
repita enquanto t
	a = a + 1
fim

bool b
repita enquanto b
	a = a + 1
fim

