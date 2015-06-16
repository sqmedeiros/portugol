local linha

local token =  { }

-- O campo 'cod' representa o codigo que deve ser gerado para um token
-- no caso de uma traducao para C/C++
-- O campo 's' indica qual eh o texto no programa fonte associado a um token

local function insereToken (s, op, cod)
	token[s] = { s = s, op = op, cod = cod }
end

insereToken(">=", "opMaiorIg", ">=")
insereToken(">", "opMaior", ">")
insereToken("<=", "opMenorIg", "<=")
insereToken("<", "opMenor", "<")
insereToken("==", "opIgual", "==")
insereToken("=", "opAtrib", "=")
insereToken("+", "opSoma", "+")
insereToken("-", "opSub", "-")
insereToken("*", "opMult", "*")
insereToken("/", "opDiv", "/")
insereToken("mod", "opMod", "%")
insereToken("e", "opE", "&&")
insereToken("ou", "opOu", "||")
insereToken("nao", "opNao", "!")
insereToken("nao=", "opDif", "!=")

local Tipo = { naotipado = {}, bool = {}, inteiro = {}, numero = {}, texto = {}, vazio = {} }

local Tag = { expBool = {}, expInt = {}, expNum = {}, expTexto = {},
              expVar = {}, opNumExp = {}, opCompExp = {}, opBoolExp = {},
              cmdAtrib = {}, cmdRepita = {}, cmdSe = {}, cmdSenaoSe = {},
              cmdChamada = {}, expChamada = {}, expNao = {},
              decVar = {}, decVarLista = {}, bloco = {}, blocoSenaoSe = {},
}

for k, v in pairs(Tag) do
	Tag[k] = k
end

for k, v in pairs(Tipo) do
	Tipo[k] = k
end

local function getToken (s)
	assert(token[s])
	local v = token[s]
	return { op = v.op, cod = v.cod, s = s } 
end

local function getTipo (t)
  assert(Tipo[t], t)
	return Tipo[t]
end

return {
	linha = linha,
	getToken = getToken,
  getTipo = getTipo,
	Tipo = Tipo,
	Tag = Tag,
}

