local m = require'lpeglabel'
local re = require 'relabel'
local arvore = require 'arvore'
local defs = require 'defs'
local semantica = require 'semantica'
local erro = require 'erro'
local gerador = require 'gerador'
local interpretador = require 'interpretador'

local terror = {}

local function newError(l, msg)
	table.insert(terror, { l = l, msg = msg} )
end

newError("erroExpSe", "expressão esperada após 'se'")
newError("erroExpSenaoSe", "expressão esperada após 'senaose'")
newError("erroExpEnq", "expressão esperada após 'enquanto'")
newError("erroExpAtrib", "expressão esperada após '='")
newError("erroExpNao", "expressão esperada após 'nao'")
newError("erroExpPar", "expressão esperada após '('")
newError("erroExpVirg", "expressão esperada após ','")
newError("erroExp", "expressão mal formada")
newError("erroDecNome", "nome esperado após ','")
newError("erroFim", "'fim' esperado no final do comando")
newError("erroEnquanto", "'enquanto' esperado após 'repita'")
newError("erroAtrib", "'=' esperado")
newError("erroFuncPredef", "'(' esperado após o nome da função")
newError("erroFechaPar", "Caractere ')' esperado")
newError("erroIndefinido", "indefinido")


local function incLinha()
	defs.linha = defs.linha + 1
end

local function countLine(s, i)
	defs.linha = 1
	local p = re.compile([[
		S <- (%nl -> incLinha  / .)*
	]], { incLinha = incLinha}) 
	p:match(s:sub(1, i))
	return true
end

local labelCode = {}
for k, v in ipairs(terror) do 
	labelCode[v.l] = k
end

local predef = { ["countLine"] = countLine,
                 ["incLinha"] = incLinha,
                 ["noExp"] = arvore.noExp,
                 ["noNaoExp"] = arvore.noNaoExp,
                 ["noMenosUnario"] = arvore.noMenosUnario,
                 ["noId"] = arvore.noId,
                 ["noInteiro"] = arvore.noInteiro,
                 ["noReal"] = arvore.noReal,
                 ["noTexto"] = arvore.noTexto,
                 ["noBoolFalso"] = arvore.noBoolFalso,
                 ["noBoolVerd"] = arvore.noBoolVerd,
                 ["noOpNumExp"] = arvore.noOpNumExp,
								 ["noOpCompExp"] = arvore.noOpCompExp,
								 ["noOpBoolExp"] = arvore.noOpBoolExp,
								 ["noCmdAtrib"] = arvore.noCmdAtrib,
								 ["noCmdRepita"] = arvore.noCmdRepita,
								 ["noCmdSe"] = arvore.noCmdSe,
								 ["noCmdSenaoSe"] = arvore.noCmdSenaoSe,
								 ["noChamadaFunc"] = arvore.noChamadaFunc,
								 ["noCmdChamada"] = arvore.noCmdChamada,
								 ["noDecVarL"] = arvore.noDecVarL,
								 ["noDecVar"] = arvore.noDecVar,
								 ["noBloco"] = arvore.noBloco
}

predef["getToken"] = defs.getToken
predef["getTipo"] = defs.getTipo

re.setlabels(labelCode)

-- ajustar mensagem de erro no primeiro "Nome" em DecVarAtrib

local g = re.compile([[
  Programa     <- Sp Bloco (!. / ErroIndefinido)
  Bloco        <- (DecVar / Comando)* -> noBloco
  DecVar       <- (Tipo (DecVarAtrib (VIRG DecVarAtrib)*)) -> noDecVarL
  DecVarAtrib  <- ((Nome / ErroDecNome) (ATRIB (Exp / ErroExpAtrib))?) -> noDecVar
  Comando      <- CmdSe / 
                  CmdRepita / 
                  CmdAtrib  / ChamadaFunc -> noCmdChamada
  CmdSe        <- (SE (Exp / ErroExpSe)  Bloco CmdSenaoSe CmdSenao CmdFim) -> noCmdSe
	CmdSenaoSe   <- (SENAOSE  (Exp / ErroExpSenaoSe) Bloco)* -> noCmdSenaoSe
  CmdSenao     <- (SENAO Bloco)? 
  CmdRepita    <- REPITA  (ENQUANTO / ErroEnquanto)  ((Exp / ErroExpEnq)  Bloco) -> noCmdRepita  CmdFim
  CmdAtrib     <- (Nome  (ATRIB / ErroAtrib) (Exp / ErroExpAtrib)) -> noCmdAtrib
  CmdFim       <- (FIM  /  ErroFim)
  Exp          <- (ExpE  (OU (ExpE / ErroExp))*) -> noOpBoolExp
  ExpE         <- (ExpIgual (E ExpIgual)*) -> noOpBoolExp
  ExpIgual     <- (ExpComp ((IGUAL / NAOIGUAL) ExpComp)*) -> noOpCompExp
  ExpComp      <- (ExpSomaSub (OPCOMP ExpSomaSub)*) -> noOpCompExp
  ExpSomaSub   <- (Termo  ((SOMA / SUB)  (Termo / ErroExp))*) -> noOpNumExp
  Termo        <- (Fator  ((MULT / DIV / MOD)  (Fator / ErroExp))*) -> noOpNumExp
  Fator        <- (NAO (Fator / ErroExpNao)) -> noNaoExp  /
									(SUB (Fator / ErroExp)) -> noMenosUnario / 
                  ABREPAR  (Exp / ErroExpPar)  (FECHAPAR / ErroFechaPar)  /
                  ChamadaFunc / Numero  / Nome  / Cadeia / VERDADEIRO / FALSO
  ChamadaFunc  <- ((FuncPredef / Nome ABREPAR) ListaExp (FECHAPAR / ErroFechaPar)) -> noChamadaFunc
  FuncPredef   <- (ENTRADA / SAIDA) -> noId (ABREPAR / ErroFuncPredef)
  ListaExp     <- (Exp (VIRG (Exp / ErroExpVirg))*)*
  Nome         <- !RESERVADA {LETRA RestoNome*} -> noId Sp
  RestoNome    <- (LETRA / [0-9] / '_')
  FimNome      <- !RestoNome Sp
  Numero       <- Real / Inteiro 
	Inteiro      <- [0-9]+ -> noInteiro Sp 
  Real         <- ([0-9]* '.' [0-9]+ / [0-9]+ '.' [0-9]*) -> noReal Sp
  FALSO        <- 'falso' -> noBoolFalso FimNome
  VERDADEIRO   <- 'verdadeiro' -> noBoolVerd FimNome
  Cadeia       <- '"' (!'"' .)* -> noTexto '"' Sp
  Tipo         <- INTEIRO / NUMERO / TEXTO / BOOLEANO
	RESERVADA    <- SE / SENAOSE / SENAO / FIM / ENTRADA / REPITA / ENQUANTO / SAIDA /
                  INTEIRO / NUMERO / TEXTO / BOOLEANO / FALSO / VERDADEIRO / MOD /
                  E / OU / NAOIGUAL / NAO
  SE           <- 'se' FimNome
  SENAOSE      <- 'senaose' FimNome
  SENAO        <- 'senao' FimNome
  FIM          <- 'fim' FimNome
  ENTRADA      <- 'entrada' FimNome
  REPITA       <- 'repita' FimNome
  ENQUANTO     <- 'enquanto' FimNome
  SAIDA        <- 'saida' FimNome
  INTEIRO      <- 'inteiro' -> getTipo FimNome
  NUMERO       <- 'numero' -> getTipo FimNome 
  TEXTO        <- 'texto' -> getTipo FimNome
  BOOLEANO     <- 'bool' -> getTipo FimNome
  MOD          <- 'mod' -> getToken FimNome
  E            <- 'e' -> getToken FimNome
  OU           <- 'ou' -> getToken FimNome
	NAOIGUAL     <- 'nao=' -> getToken Sp
  NAO          <- 'nao' -> getToken FimNome
	OPCOMP       <- MAIORIGUAL / MAIOR / MENORIGUAL / MENOR 
  MAIORIGUAL   <- '>=' -> getToken Sp
  MAIOR        <- '>' -> getToken Sp
  MENORIGUAL   <- '<=' -> getToken Sp
  MENOR        <- '<' -> getToken Sp
  IGUAL        <- '==' -> getToken Sp
  ATRIB        <- '=' !'=' Sp
	LETRA        <- [a-z] / [A-Z]
  ABREPAR      <- '(' Sp
  SOMA         <- '+' -> getToken Sp 
  SUB          <- '-' -> getToken Sp
  MULT         <- '*' -> getToken Sp
  DIV          <- '/' -> getToken Sp
  FECHAPAR     <- ')' Sp
  VIRG         <- ',' Sp
	Sp           <- (%nl -> incLinha / %s)* 
	ErroExpSe      <- ErrCount %{erroExpSe}
	ErroExpSenaoSe <- ErrCount %{erroExpSenaoSe}
	ErroExpEnq     <- ErrCount %{erroExpEnq}
	ErroFim        <- ErrCount %{erroFim}
	ErroEnquanto   <- ErrCount %{erroEnquanto}
	ErroExpAtrib   <- ErrCount %{erroExpAtrib}
	ErroExpNao     <- ErrCount %{erroExpNao}
	ErroExpPar     <- ErrCount %{erroExpPar}
	ErroExpVirg    <- ErrCount %{erroExpVirg}
	ErroExp        <- ErrCount %{erroExp}
	ErroDecNome    <- ErrCount %{erroDecNome}
	ErroFechaPar   <- ErrCount %{erroFechaPar}
	ErroFuncPredef <- ErrCount %{erroFuncPredef}
	ErroIndefinido <- ErrCount %{erroIndefinido}
	ErroAtrib      <- ErrCount %{erroAtrib}
	ErrCount       <- '' => countLine

]], predef)


local function imprimeErro(n, e)
	assert(n == nil)
	print("(Erro) Perto da linha " .. defs.linha .. ": " .. terror[e].msg)
end

local function parse(s)
  defs.linha = 1
	return g:match(s)
end

local function parse2(s)
  local t, v = parse(s)
	if not t then
		imprimeErro(t, v)
	end
	return t
end


local function teste (nome)
	local f = io.open(nome)
	if not f then
		error("Erro ao tentar abrir " .. nome)
	end
	local s = f:read("*a")
	f:close()
	erro.inicia()
	return parse(s)
end

local function compila (arqEntrada, arqSaida)
	local t, v = teste(arqEntrada)
	if not t then
		imprimeErro(t, v)
	else
  	semantica.analisaPrograma(t)
		local terro = erro.getErros()
		if #terro > 0 then
			for i, v in ipairs(terro) do
				print(v)
			end
		else
			local prog = gerador.geraPrograma(t)
			arqSaida = arqSaida or "tmp.cpp"
			local saida = io.open(arqSaida, "w")
			saida:write(prog)
			saida:close()
		end
	end
end

local function interpreta (arqEntrada)
	local t, v = teste(arqEntrada)
	if not t then
		imprimeErro(t, v)
	else
  	semantica.analisaPrograma(t)
		local terro = erro.getErros()
		if #terro > 0 then
			for i, v in ipairs(terro) do
				print(v)
			end
		else
			interpretador.executa(t)
		end
	end
end


return {
	parse = parse,
	parse2 = parse2,
  imprimeErro = imprimeErro,
	compila = compila,
	interpreta = interpreta
}


