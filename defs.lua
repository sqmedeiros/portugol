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

local TipoTag = { array = {}, simples = {}, naotipado = {} }

local TipoBasico = { naotipado = {}, bool = {}, inteiro = {}, numero = {}, texto = {}, vazio = {} }

local Tag = { decVar = {}, decFuncao = {}, decArrayVar = {}, decVarLista = {}, bloco = {},
              cmdAtrib = {}, cmdRepita = {}, cmdSe = {}, cmdSenaoSe = {}, cmdRetorne = {},
              blocoSenaoSe = {},
              expBool = {}, expInt = {}, expNum = {}, expTexto = {}, expNovoArray = {},
              expSimpVar = {}, expArrayVar = {}, expOpNum = {}, expOpComp = {}, expOpBool = {},
              cmdChamada = {}, expChamada = {}, expNao = {},
}

for k, v in pairs(Tag) do
	Tag[k] = k
end

for k, v in pairs(TipoBasico) do
	TipoBasico[k] = k
end

for k, v in pairs(TipoTag) do
	TipoTag[k] = k
end

local function getToken (s)
	assert(token[s])
	local v = token[s]
	return { op = v.op, cod = v.cod, s = s } 
end

local function getTipoBasico(t)
  assert(TipoBasico[t], t)
	return TipoBasico[t]
end

return {
	linha = linha,
	getToken = getToken,
  getTipoBasico = getTipoBasico,
	Tag = Tag,
	TipoTag = TipoTag,
	TipoBasico = TipoBasico,
}

