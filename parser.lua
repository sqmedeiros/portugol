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
newError("erroExpArray", "expressão esperada após '['")
newError("erroExp", "expressão mal formada")
newError("erroDecNome", "nome esperado após ',' ou declaração de tipo")
newError("erroDecNomeFun", "nome esperado após 'funcao'")
newError("erroFim", "'fim' esperado no final do comando")
newError("erroFunFim", "'fim' esperado no final da função")
newError("erroEnquanto", "'enquanto' esperado após 'repita'")
newError("erroAtrib", "'=' esperado após variável")
newError("erroTipo", "nome de tipo esperado após 'novo'")
newError("erroTipoVirg", "nome de tipo esperado após ','")
newError("erroFuncPredef", "'(' esperado após o nome da função")
newError("erroFechaPar", "caractere ')' esperado")
newError("erroFechaCol", "caractere ']' esperado")
newError("erroAbreCol", "caractere '[' esperado")
newError("erroNovoExpArray", "erro ao inicializar array")
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
								 ["noCmdRetorne"] = arvore.noCmdRetorne,
								 ["noKwRetorne"] = arvore.noKwRetorne,
								 ["noDecVarL"] = arvore.noDecVarL,
								 ["noListaParam"] = arvore.noListaParam,
								 ["noDecVar"] = arvore.noDecVar,
								 ["noDecFuncao"] = arvore.noDecFuncao,
								 ["noDecArrayVar"] = arvore.noDecArrayVar,
								 ["noBloco"] = arvore.noBloco,
								 ["noNovoArrayExp"] = arvore.noNovoArrayExp,
								 ["noTipo"] = arvore.noTipo,	
								 ["noVar"] = arvore.noVar	
}

predef["getToken"] = defs.getToken
predef["getTipoBasico"] = defs.getTipoBasico

re.setlabels(labelCode)

--TODO: ver o erro quando um expressão é esperada
-- atualmente uma Exp sempre casa, o que não dispara a regra ErroExp
local g = re.compile([[
  Programa     <- Sp BlocoExt (!. / ErroIndefinido)
  BlocoExt     <- (DecFunc / DecVar / Comando)* -> noBloco
  BlocoInt     <- (DecVar / Comando)* -> noBloco
  DecFunc      <- (FUNCAO (Nome / ErroDecNomeFun) ABREPAR ListaParam FECHAPAR RetornaDec? BlocoInt FunFim) -> noDecFuncao
	RetornaDec   <- RETORNA Tipo
  DecVar       <- (Tipo (DecVarAtrib (VIRG DecVarAtrib)*)) -> noDecVarL
  ListaParam   <- (Tipo (Nome / ErroDecNome) (VIRG (Tipo / ErroTipoVirg) (Nome / ErroDecNome))*)? -> noListaParam
  DecVarAtrib  <- ((Nome / ErroDecNome) (ATRIB (Exp / ErroExpAtrib))?) -> noDecVar
	Comando      <- CmdSe / 
                  CmdRepita / 
                  ChamadaFunc -> noCmdChamada /
                  CmdAtrib  / 
                  CmdRetorne
  CmdSe        <- (SE (Exp / ErroExpSe)  BlocoInt CmdSenaoSe CmdSenao CmdFim) -> noCmdSe
	CmdSenaoSe   <- (SENAOSE  (Exp / ErroExpSenaoSe) BlocoInt)* -> noCmdSenaoSe
  CmdSenao     <- (SENAO BlocoInt)? 
  CmdRepita    <- REPITA  (ENQUANTO / ErroEnquanto)  ((Exp / ErroExpEnq)  BlocoInt) -> noCmdRepita  CmdFim
  CmdAtrib     <- (Var (ATRIB / ErroAtrib) (Exp / ErroExpAtrib)) -> noCmdAtrib
  CmdRetorne   <- (RETORNE Exp?) -> noCmdRetorne
  CmdFim       <- (FIM  /  ErroFim)
  FunFim       <- (FIM  /  ErroFunFim)
  Exp          <- (ExpE  (OU (ExpE / ErroExp))*) -> noOpBoolExp
  ExpE         <- (ExpIgual (E ExpIgual)*) -> noOpBoolExp
  ExpIgual     <- (ExpComp ((IGUAL / NAOIGUAL) ExpComp)*) -> noOpCompExp
  ExpComp      <- (ExpSomaSub (OPCOMP ExpSomaSub)*) -> noOpCompExp
  ExpSomaSub   <- (Termo  ((SOMA / SUB)  (Termo / ErroExp))*) -> noOpNumExp
  Termo        <- (Fator  ((MULT / DIV / MOD)  (Fator / ErroExp))*) -> noOpNumExp
  Fator        <- (NAO (Fator / ErroExpNao)) -> noNaoExp  /
									(SUB (Fator / ErroExp)) -> noMenosUnario /
                  NOVO ((TipoBase / ErroTipo) ((ABRECOL / ErroAbreCol) (Exp / ErroExpArray) (FECHACOL / ErroFechaCol)) 
                                              (ABRECOL (Exp / '' -> 'nil') (FECHACOL / ErroFechaCol))*) -> noNovoArrayExp   / 
                  ABREPAR  (Exp / ErroExpPar)  (FECHAPAR / ErroFechaPar)  /
                  ChamadaFunc / Numero  / Var  / Cadeia / VERDADEIRO / FALSO
  ChamadaFunc  <- ((FuncPredef -> noId (ABREPAR / ErroFuncPredef) / Nome ABREPAR) ListaExp (FECHAPAR / ErroFechaPar)) -> noChamadaFunc
  FuncPredef   <- ENTRADA / SAIDA / TEXTOCOMP / TEXTOSUB / TEXTOPOS
  ListaExp     <- (Exp (VIRG (Exp / ErroExpVirg))*)*
  Var          <- (Nome (ABRECOL (Exp / ErroExpArray) (FECHACOL / ErroFechaCol))*) -> noVar
  Nome         <- !RESERVADA {LETRA RestoNome*} -> noId Sp
  RestoNome    <- (LETRA / [0-9] / '_')
  FimNome      <- !RestoNome Sp
  Numero       <- Real / Inteiro 
	Inteiro      <- [0-9]+ -> noInteiro Sp 
  Real         <- ([0-9]* '.' [0-9]+ / [0-9]+ '.' [0-9]*) -> noReal Sp
  FALSO        <- 'falso' -> noBoolFalso FimNome
  VERDADEIRO   <- 'verdadeiro' -> noBoolVerd FimNome
  Cadeia       <- '"' (!'"' .)* -> noTexto '"' Sp
  Tipo         <- (TipoBase ({ABRECOL FECHACOL})*) -> noTipo
  TipoBase     <- INTEIRO / NUMERO / TEXTO / BOOLEANO
	RESERVADA    <- SE / SENAOSE / SENAO / FIM / REPITA / ENQUANTO /
                  INTEIRO / NUMERO / TEXTO / BOOLEANO / FALSO / VERDADEIRO / MOD /
                  E / OU / NAOIGUAL / NAO / NOVO / FUNCAO / RETORNA / RETORNE / FuncPredef
  SE           <- 'se' FimNome
  SENAOSE      <- 'senaose' FimNome
  SENAO        <- 'senao' FimNome
  FIM          <- 'fim' FimNome
  FUNCAO       <- 'funcao' FimNome
  RETORNA      <- 'retorna' FimNome
  RETORNE      <- 'retorne' FimNome -> noKwRetorne
  ENTRADA      <- {'leia'} FimNome
  SAIDA        <- {'escreva'} FimNome
  TEXTOCOMP    <- {'textoComp'} FimNome
  TEXTOSUB     <- {'textoSub'} FimNome
  TEXTOPOS     <- {'textoPos'} FimNome
  REPITA       <- 'repita' FimNome
  ENQUANTO     <- 'enquanto' FimNome
  INTEIRO      <- 'inteiro' -> getTipoBasico FimNome
  NUMERO       <- 'numero' -> getTipoBasico FimNome 
  TEXTO        <- 'texto' -> getTipoBasico FimNome
  BOOLEANO     <- 'bool' -> getTipoBasico FimNome
  MOD          <- 'mod' -> getToken FimNome
  E            <- 'e' -> getToken FimNome
  OU           <- 'ou' -> getToken FimNome
	NAOIGUAL     <- 'nao=' -> getToken Sp
  NAO          <- 'nao' -> getToken FimNome
  NOVO         <- 'novo' FimNome
	OPCOMP       <- MAIORIGUAL / MAIOR / MENORIGUAL / MENOR 
  MAIORIGUAL   <- '>=' -> getToken Sp
  MAIOR        <- '>' -> getToken Sp
  MENORIGUAL   <- '<=' -> getToken Sp
  MENOR        <- '<' -> getToken Sp
  IGUAL        <- '==' -> getToken Sp
  ATRIB        <- '=' !'=' Sp
	LETRA        <- [a-z] / [A-Z]
  ABRECOL      <- '[' Sp
  ABREPAR      <- '(' Sp
  SOMA         <- '+' -> getToken Sp 
  SUB          <- '-' -> getToken Sp
  MULT         <- '*' -> getToken Sp
  DIV          <- '/' -> getToken Sp
  FECHACOL     <- ']' Sp
  FECHAPAR     <- ')' Sp
  VIRG         <- ',' Sp
	Sp           <- (%nl -> incLinha / %s / Comentario)*
  Comentario   <- '//' (!%nl .)*  /  '/*' (!'*/' (%nl -> incLinha / .))* '*/'  
	ErroExpSe      <- ErrCount %{erroExpSe}
	ErroExpSenaoSe <- ErrCount %{erroExpSenaoSe}
	ErroExpEnq     <- ErrCount %{erroExpEnq}
	ErroFim        <- ErrCount %{erroFim}
	ErroFunFim     <- ErrCount %{erroFunFim}
	ErroEnquanto   <- ErrCount %{erroEnquanto}
	ErroExpAtrib   <- ErrCount %{erroExpAtrib}
	ErroExpNao     <- ErrCount %{erroExpNao}
	ErroExpPar     <- ErrCount %{erroExpPar}
	ErroExpVirg    <- ErrCount %{erroExpVirg}
	ErroExpArray   <- ErrCount %{erroExpArray}
	ErroExp        <- ErrCount %{erroExp}
	ErroDecNome    <- ErrCount %{erroDecNome}
	ErroDecNomeFun <- ErrCount %{erroDecNomeFun}
	ErroFechaPar   <- ErrCount %{erroFechaPar}
	ErroFechaCol   <- ErrCount %{erroFechaCol}
	ErroAbreCol    <- ErrCount %{erroAbreCol}
	ErroNovoExpArray <- ErrCount %{erroNovoExpArray}
	ErroFuncPredef <- ErrCount %{erroFuncPredef}
	ErroIndefinido <- ErrCount %{erroIndefinido}
	ErroAtrib      <- ErrCount %{erroAtrib}
	ErroTipo       <- ErrCount %{erroTipo}
	ErroTipoVirg   <- ErrCount %{erroTipoVirg}
	ErrCount       <- '' => countLine

]], predef)


local function imprimeErro(n, e, serror)
	assert(n == nil)
	local j = string.find(serror, "\n")
	if j ~= nil then
		j = j - 1
	end
	local s = string.sub(serror, 1, j)
	if terror[e].msg == "indefinido" then
		print('(Erro) Perto da linha ' .. defs.linha .. ' ao tentar reconhecer "' .. s .. '"')
	else
		print('(Erro) Perto da linha ' .. defs.linha .. ': ' .. terror[e].msg)
	end
end

local function parse(s)
  defs.linha = 1
	return g:match(s)
end

local function parse2(s)
  local t, v, serror = parse(s)
	if not t then
		imprimeErro(t, v, serror)
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
	local t, v, serror = teste(arqEntrada)
	if not t then
		imprimeErro(t, v, serror)
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


