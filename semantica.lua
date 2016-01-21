local defs = require 'defs'
local tabsim = require 'tabsimbolos'
local arvore = require 'arvore'
local tipo = require 'tipo'
local erro = require 'erro'

erro = erro.erro

local TipoTag = defs.TipoTag
local TipoBasico = defs.TipoBasico
local Tag = defs.Tag

local analisaBloco

function analisaExp (exp, ambiente)
	assert(ambiente, "Ambiente nulo")

  -- expBool, expInt, expNum, expTexto
	--if exp.tipo ~= Tipo.naotipado then
		--return exp.tipo
	--end

	local tag = exp.tag
	if tag == Tag.expNao then
		analisaExpNao(exp, ambiente)
	elseif tag == Tag.expVar then
		analisaExpVar(exp, ambiente)
	elseif tag == Tag.expArray then
		analisaExpArray(exp, ambiente)
	elseif tag == Tag.expOpNum then
		analisaExpOpNum(exp, ambiente)
	elseif tag == Tag.expOpComp then
		analisaExpOpComp(exp, ambiente)
	elseif tag == Tag.expOpBool then
		analisaExpOpBool(exp, ambiente)
	elseif tag == Tag.expInt or tag == Tag.expNum or
         tag == Tag.expBool or tag == Tag.expTexto then
		return
	elseif tag == Tag.expChamada then
		error("Falta analisar chamada de função")
	else
		error("Expressão desconhecida " .. exp.tag)	
	end
end

function analisaExpNao (exp, ambiente)
	analisaExp(exp.exp, ambiente)
	local tipo = exp.exp.tipo 
	if tipo.tag ~= TipoTag.simples or tipo.basico ~= TipoBasico.bool then
		erro("expressão do '" .. exp.op.s .. "' deve ser do tipo booleano", exp.exp.linha)
	end
end

function analisaExpVar (exp, ambiente)
	local v = tabsim.procuraSimbolo(exp, ambiente)
	if v ~= nil then
		exp.tipo = v.tipo 
	end
end

function analisaExpArray (exp, ambiente)
	--print("expArray", exp, exp.v, exp.tipo, exp.tipo.basico, exp.tipo.tag)
	local v = tabsim.procuraSimbolo(exp, ambiente)
	if v ~= nil then
		if v.tipo.tag ~= TipoTag.array then
			erro("variável " .. exp.v .. " não é um array", exp.linha)
		end
		exp.tipo = v.tipo
	end
	local idxExp = exp.exp
	analisaExp(idxExp, ambiente)
	
	if idxExp.tipo.tag ~= TipoTag.simples or idxExp.tipo.basico ~= TipoBasico.inteiro then
		erro("a expressão que indexa '" .. exp.v.v .. "' deve ser do tipo inteiro", idxExp.linha)
	end
end

function analisaExpOpNum (exp, ambiente)
	local p1 = exp.p1
	local p2 = exp.p2
	analisaExp(p1, ambiente)
	analisaExp(p2, ambiente)

	if tipo.naoTipado(p1.tipo) or tipo.naoTipado(p2.tipo) then
		return
	end
	
	if p1.tipo.tag ~= TipoTag.simples or p2.tipo.tag ~= TipoTag.simples then
		erro("operandos inválidos para o operador binário'" .. exp.op.s .. "'", exp.linha)
	end

	local tb1 = p1.tipo.basico
	local tb2 = p2.tipo.basico
	if tipo.tiposCompativeis(tb1, TipoBasico.numero) and tipo.tiposCompativeis(tb2, TipoBasico.numero) then
		if exp.op.op == "opMod" then
			if tb1 ~= TipoBasico.inteiro or tb2 ~= TipoBasico.inteiro then
				local s = "os operandos de '" .. exp.op.s .. "' devem ser do tipo inteiro"
				erro(s, exp.linha)
			else
				exp.tipo.basico = TipoBasico.inteiro
			end
		elseif tb1 == TipoBasico.numero or tb2 == TipoBasico.numero then
			exp.tipo.basico = TipoBasico.numero
		else
			exp.tipo.basico = TipoBasico.inteiro	
		end
	elseif	tipo.tiposCompativeis(tb1, TipoBasico.texto) and tipo.tiposCompativeis(tb2, TipoBasico.texto) and
          exp.op.op == "opSoma" then
			exp.tipo.basico = TipoBasico.texto	
	else
		local s = "não é possível realizar a operação " .. exp.op.s .. " com uma expressão do tipo " .. tb1
  	s = s .. " e uma expressão do tipo " .. tb2
		erro(s, exp.linha)
	end
end
	

function analisaExpOpComp (exp, ambiente)
	local p1 = exp.p1
	local p2 = exp.p2

	assert(exp.tipo.basico == TipoBasico.bool and exp.tipo.tag == TipoTag.simples)
	
	analisaExp(p1, ambiente)
	analisaExp(p2, ambiente)

	if tipo.naoTipado(p1.tipo) or tipo.naoTipado(p2.tipo) then
		return
	end

	if p1.tipo.tag ~= TipoTag.simples or p2.tipo.tag ~= TipoTag.simples then
		erro("operandos inválidos para o operador binário'" .. exp.op.s .. "'", exp.linha)
	end

	if not tipo.tiposCompativeis(p1.tipo.basico, p2.tipo.basico) then
		local s = "não é possível comparar uma expressão do tipo " .. p1.tipo.basico
    s = s .. " com uma expressão do tipo " .. p2.tipo.basico
		erro(s, p1.linha)
	end
end

function analisaExpOpBool (exp, ambiente)
	local p1 = exp.p1 
	local p2 = exp.p2

	analisaExp(p1, ambiente)
	analisaExp(p2, ambiente)

	if tipo.naoTipado(p1.tipo) or tipo.naoTipado(p2.tipo) then
		return
	end

	if p1.tipo.tag ~= TipoTag.simples or p2.tipo.tag ~= TipoTag.simples then
		erro("operandos inválidos para o operador binário'" .. exp.op.s .. "'", exp.linha)
	end

	if not tipo.tiposCompativeis(p1.tipo.basico, TipoBasico.bool) or 
     not tipo.tiposCompativeis(p2.tipo.basico, TipoBasico.bool) then
		local s = "expressões do '" .. exp.op.s .. "' devem ser do tipo booleano"
		erro(s, p1.linha)
	end
end


local function analisaAtrib (var, exp, ambiente)
	analisaExp(exp, ambiente)
	
	if tipo.naoTipado(exp.tipo) then
		return
	end

	--print("analisaAtrib ", var, var.v, var.tipo)
	if not tipo.tiposCompativeis(var.tipo.basico, exp.tipo.basico, true) then
		local s = "não pode atribuir expressão do tipo " .. exp.tipo.basico .. " à variável "
    s = s .. "'" .. var.v .. "' do tipo " .. var.tipo.basico
		erro(s, var.linha)
	end
end

local function analisaDecVar (decVar, ambiente)
	if decVar.exp then
		analisaAtrib(decVar, decVar.exp, ambiente)
	end
	tabsim.insereSimbolo(decVar, ambiente)
end


local function ehTamArrayValido (exp)
	if exp.tag == Tag.expInt then
		return true
	elseif exp.tag == Tag.expVar then --TODO: mudar depois pra aceitar variaveis inicializadas
		return false
	elseif exp.tag == Tag.expOpNum then
		return ehTamArrayValido(exp.p1) and ehTamArrayValido(exp.p2)
	else
		return false
	end
end


local function analisaDecArrayVar (decArrayVar, ambiente)
	analisaExp(decArrayVar.tam, ambiente)
	
	if tipo.naoTipado(decArrayVar.tam.tipo) then
		return
	end	

	if not tipo.tiposCompativeis(decArrayVar.tam.tipo.basico, TipoBasico.inteiro) then
		local s = "tamanho do array deve ser uma expressão do tipo inteiro"
		erro(s, decArrayVar.tam.linha)
	--elseif not ehTamArrayValido(decArrayVar.tam) then
			--local s = "tamanho do array deve poder ser determinado em tempo de compilação"
	--		local s = "expressão que define o tamanho do array deve ser constantepoder ser determinado em tempo de compilação"
	--		erro(s, decArrayVar.tam.linha)
	end

	--if decArrayVar.exp then  TODO: permitir inicializar o array na declaração
		--analisaTipoAtrib(decArrayVar.v, decArrayVar.exp, ambiente)
	--end
	--print("DecArrayVar ", decArrayVar.v, decArrayVar.var)
	tabsim.insereSimbolo(decArrayVar, ambiente, true)
end


local function analisaDecVarLista (listaDec, ambiente)
	for i, v in ipairs(listaDec) do
		if v.tag == Tag.decArrayVar then
			analisaDecArrayVar(v, ambiente)
		else
			analisaDecVar(v, ambiente)
		end
	end
end

local function analisaExpCmd (exp, ambiente)
	analisaExp(exp, ambiente)

	if tipo.naoTipado(exp.tipo) then
		return
	end	

	if not tipo.tiposCompativeis(exp.tipo.basico, TipoBasico.bool) then
		local s = "expressão do 'se' deve ser booleana"
		erro(s, exp.linha)
	end

end

local function analisaCmdSe (c, ambiente)
	analisaExpCmd(c.expSe, ambiente)

	analisaBloco(c.blocoSe, ambiente)

	if c.senaoSe then
		local lista = c.senaoSe.lista
		for i, v in ipairs(lista) do
			analisaExpCmd(v.exp, ambiente)
			analisaBloco(v.bloco, ambiente)
		end
	end

	if c.senao then
		analisaBloco(c.senao, ambiente)
	end	
end

local function analisaCmdRepita (c, ambiente)
	analisaExpCmd(c.exp, ambiente)
	analisaBloco(c.bloco, ambiente)
end

function analisaCmdChamada (c, ambiente)
	if c.nome.v == "saida" then
		for i, v in ipairs(c.args) do
			analisaExp(v, ambiente)
		end	
	elseif c.nome.v == "entrada" then
		for i, v in ipairs(c.args) do
			analisaExp(v, ambiente)
		end	
	else
		error("Função inválida")
	end
end

local function analisaComando (c, ambiente)
	if c.tag == Tag.cmdAtrib then
		local var = tabsim.procuraSimbolo(c.p1, ambiente)
		local exp = c.p2
		if var ~= nil then
			c.p1.tipo = var.tipo
			--print("analisaComando ", var, var.v, var.tipo, c.p1.tipo)
			analisaAtrib(c.p1, exp, ambiente)
		end
	elseif c.tag == Tag.cmdSe then
		analisaCmdSe(c, ambiente)
	elseif c.tag == Tag.cmdRepita then
		analisaCmdRepita(c, ambiente)
	elseif c.tag == Tag.cmdChamada then
		analisaCmdChamada(c, ambiente)
	else
		error("Comando desconhecido")
	end
end

function analisaBloco (bloco, ambiente)
	tabsim.entraBloco(ambiente)
	for i, v in ipairs(bloco.tbloco) do	
		if v.tag == Tag.decVarLista then
			analisaDecVarLista(v.lista, ambiente)
		elseif arvore.ehComando(v) then
			analisaComando(v, ambiente)
		else
			erro("Tag inválida: " .. tostring(v.tag), bloco.linha)
		end
	end
	tabsim.saiBloco(ambiente)	
end

local function analisaPrograma (t)
	local ambiente = tabsim.criaAmbiente() 
	
	if t.tag == Tag.bloco then
		analisaBloco(t, ambiente)
	else
		erro("Estrutura inválida", t.linha)
	end
end


return {
	analisaPrograma = analisaPrograma
}
