inteiro a = 1
numero b = 3.4
bool c1 = falso, c2 = verdadeiro
texto t = "alex"

repita enquanto a > 0
	saida("Digite o novo valor de a: ")
	entrada(a)
  se a mod 2 nao= 0 e nao a mod 5 == 0
    saida(a, " eh par")
  senaose a mod 3 == 0
    saida(a, " eh divisivel por 3")
  senao
    saida(a, " eh impar")
  fim
fim

