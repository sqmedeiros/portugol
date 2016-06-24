local defs = require 'defs'
local tabsim = require 'tabsimbolos'
local arvore = require 'arvore'
local tipo = require 'tipo'
local erro = require 'erro'

erro = erro.erro

local TipoTag = defs.TipoTag
local TipoBasico = defs.TipoBasico
local Tag = defs.Tag

local analisaBloco, analisaExpNao
local analisaExpSimpVar, analisaExpArrayVar, analisaExpNovoArray
local analisaExpOpBin, analisaExpOpNum, analisaExpOpComp, analisaExpOpBool 
local analisaExpChamada, analisaListaArg

-- 0 significa um valor basico
-- 1 significa um valor de uma dimensao, etc
local function getVarDecDim (v)
	assert(v.tag == Tag.decVar or v.tag == Tag.decArrayVar, v.tag)
	return v.tipo.dim
end


-- 0 significa um valor basico
-- 1 significa um valor de uma dimensao, etc
local function getVarDim (v, ambiente)
	assert(v.tag == Tag.expSimpVar or v.tag == Tag.expArrayVar or
		     v.tag == Tag.decVar or v.tag == Tag.decArrayVar, v.tag)
	
	if v.tag == Tag.decVar or v.tag == Tag.decArrayVar then
		return getVarDecDim(v)
	end

	local ref = tabsim.procuraSimbolo(v, ambiente)
	if not ref then --nao achou variavel
		assert(false, "Nao achou " .. v.v)
		return 0 
	end
	local n = ref.tipo.dim
	if v.dim then
		n = n - v.dim
	end
	return n
end

local function ehValorBasico (v, ambiente)
	if v.tipo.tag ~= TipoTag.array then
		return true
	end
	if v.tag == Tag.expNovoArray then
		return false
	end
	-- eh uma variavel
	return getVarDim(v, ambiente) == 0
end

local function analisaExp (exp, ambiente)
	assert(ambiente, "Ambiente nulo")

  -- expBool, expInt, expNum, expTexto
	--if exp.tipo ~= Tipo.naotipado then
		--return exp.tipo
	--end

	local tag = exp.tag
	if tag == Tag.expNao then
		analisaExpNao(exp, ambiente)
	elseif tag == Tag.expSimpVar then
		analisaExpSimpVar(exp, ambiente)
	elseif tag == Tag.expArrayVar then
		analisaExpArrayVar(exp, ambiente)
	elseif tag == Tag.expOpNum then
		analisaExpOpNum(exp, ambiente)
	elseif tag == Tag.expOpComp then
		analisaExpOpComp(exp, ambiente)
	elseif tag == Tag.expOpBool then
		analisaExpOpBool(exp, ambiente)
	elseif tag == Tag.expInt or tag == Tag.expNum or
         tag == Tag.expBool or tag == Tag.expTexto then
		return
	elseif tag == Tag.expNovoArray then
		analisaExpNovoArray(exp, ambiente)
	elseif tag == Tag.expChamada then
		analisaExpChamada(exp, ambiente)
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

function analisaExpSimpVar (exp, ambiente)
	local v = tabsim.procuraSimbolo(exp, ambiente)
	if v ~= nil then
		exp.tipo = v.tipo 
	end
end

function analisaExpArrayVar (exp, ambiente)
	--print("analisaExpArrayVar", exp.v)
	local v = tabsim.procuraSimbolo(exp, ambiente)
	if v ~= nil then
		exp.tipo = v.tipo
		--print("dim", v.tipo.dim, exp.dim)
		if v.tipo.tag ~= TipoTag.array then 
			erro("variável '" .. exp.v .. "' não é um array", exp.linha)
		elseif v.tipo.dim < exp.dim then
			erro("array '" .. v.v .. "' possui somente " .. v.tipo.dim .. " dimensão(ões)", exp.linha)
		end
		for i, x in ipairs(exp.t) do	
 			analisaExp(x, ambiente)
			if x.tipo.basico ~= TipoBasico.inteiro then
				erro("a expressão que indexa um array deve ser do tipo inteiro", exp.linha)
			end
		end
	end
end


function analisaExpNovoArray (exp, ambiente)
	--print("eueueu", exp, exp.v)
	for k, v in ipairs(exp.v) do
		if v.ehExp then
			analisaExp(v, ambiente)
			--print("bla", v.tag, v.tipo.basico, TipoBasico.inteiro, v.v)
			if v.tipo.basico ~= TipoBasico.inteiro then
				erro("a expressão que indica o tamanho de um array deve ser do tipo inteiro", v.linha)
			end
			if not ehValorBasico(v, ambiente) then
				erro("a expressão que indica o tamanho de um array deve ser do tipo inteiro", v.linha)
			end 
		else
			--print("cabou analisaExpNovoArray")
			break
		end	
	end
	return exp.dim	
end


function analisaExpOpBin (exp, ambiente)
	local p1 = exp.p1
	local p2 = exp.p2

	analisaExp(p1, ambiente)
	analisaExp(p2, ambiente)

	if tipo.naoTipado(p1.tipo) or tipo.naoTipado(p2.tipo) then
		return
	end

	if not ehValorBasico(p1, ambiente) or not ehValorBasico(p2, ambiente) then 
		erro("operandos inválidos para o operador binário '" .. exp.op.s .. "'", p1.linha)
	end
end

function analisaExpOpNum (exp, ambiente)
	analisaExpOpBin(exp, ambiente)
	
	local p1 = exp.p1
	local p2 = exp.p2

	if tipo.naoTipado(p1.tipo) or tipo.naoTipado(p2.tipo) then
		return
	end

	local tb1 = p1.tipo.basico
	local tb2 = p2.tipo.basico
	--print("tb1 = ", tb1)
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
	assert(exp.tipo.basico == TipoBasico.bool and exp.tipo.tag == TipoTag.simples)

	analisaExpOpBin(exp, ambiente)

	local p1 = exp.p1
	local p2 = exp.p2
	
	if tipo.naoTipado(p1.tipo) or tipo.naoTipado(p2.tipo) then
		return
	end

	if not tipo.tiposCompativeis(p1.tipo.basico, p2.tipo.basico) then
		local s = "não é possível comparar uma expressão do tipo " .. p1.tipo.basico
    s = s .. " com uma expressão do tipo " .. p2.tipo.basico
		erro(s, p1.linha)
	end
end

function analisaExpOpBool (exp, ambiente)
	analisaExpOpBin(exp, ambiente)

	local p1 = exp.p1 
	local p2 = exp.p2

	if tipo.naoTipado(p1.tipo) or tipo.naoTipado(p2.tipo) then
		return
	end

	if not tipo.tiposCompativeis(p1.tipo.basico, TipoBasico.bool) or 
     not tipo.tiposCompativeis(p2.tipo.basico, TipoBasico.bool) then
		local s = "expressões do '" .. exp.op.s .. "' devem ser do tipo booleano"
		erro(s, p1.linha)
	end
end

function analisaExpChamada (exp, ambiente)
	if exp.nome.v == "saida" then
		for i, v in ipairs(exp.args) do
			analisaExp(v, ambiente)
		end
		exp.tipo = arvore.makeTipo(TipoTag.simples, TipoBasico.vazio)	
	elseif exp.nome.v == "entrada" then
		for i, v in ipairs(exp.args) do
			analisaExp(v, ambiente)
		end	
		exp.tipo = arvore.makeTipo(TipoTag.simples, TipoBasico.vazio)	
	elseif exp.nome.v == "textoComp" then
		if #exp.args ~= 1 then
			erro("função textoComp espera 1 parâmetro, mas foi chamada com " .. #exp.args, exp.nome.linha)
			return
		end
		local v1 = exp.args[1]	
		analisaExp(v1, ambiente)
		if v1.tipo.basico ~= TipoBasico.texto or not ehValorBasico(v1, ambiente) then
			erro("função textoComp espera parâmetro do tipo 'texto'", v1.linha)
		end
		exp.tipo = arvore.makeTipo(TipoTag.simples, TipoBasico.inteiro)
	elseif exp.nome.v == "textoSub" or exp.nome.v == "textoPos" then
		local nome = exp.nome.v
		local n = #exp.args
		if n < 2 or n > 3 or (n == 3 and nome ~= "textoSub") then
			erro("função " .. nome .. " espera 2 ou 3 parâmetros, mas foi chamada com " .. #exp.args, exp.nome.linha)
			return
		end
		local v1 = exp.args[1]	
		analisaExp(v1, ambiente)
		if v1.tipo.basico ~= TipoBasico.texto or not ehValorBasico(v1, ambiente) then
			erro("função " .. nome .. " espera primeiro parâmetro do tipo 'texto'", v1.linha)
		end

		for i = 2, #exp.args do
			local v = exp.args[i]
			analisaExp(v, ambiente)
			if v.tipo.basico ~= TipoBasico.inteiro or not ehValorBasico(v, ambiente) then
				erro("função " .. nome .. " espera " .. i .. "o parâmetro do tipo 'inteiro'", v.linha)
			end
		end	
		exp.tipo = arvore.makeTipo(TipoTag.simples, TipoBasico.texto)
	else
		error("Função inválida: " .. exp.nome.v)
	end
end

function analisaListaArg(arg, param, ambiente)
	local narg = #arg
	local nparam = #nparam
	if narg ~= nparam then
		erro("função espera " .. nparam .. " parâmetros(s), mas foi chamada com " .. narg, arg.linha)
		return
	end
	for i, v in ipairs(arg) do
		analisaExp(v, ambiente)
		if not tipo.tiposCompativeis(v.tipo.basico, param[i].tipo.basico) then
			erro("parâmetro ", v.linha)
		end
	end
end


local function analisaAtrib (var, exp, ambiente)
	if var.tag == Tag.expArrayVar then
		analisaExpArrayVar(var, ambiente)
	end	

	analisaExp(exp, ambiente)
	
	if tipo.naoTipado(exp.tipo) then
		return
	end

	--print("analisaAtrib ", var, var.v, var.tipo, var.tipo.tag, exp.dim, var.tipo.dim)
	if not tipo.tiposCompativeis(var.tipo.basico, exp.tipo.basico, true) then
		local s = "não pode atribuir expressão do tipo " .. exp.tipo.basico .. " à variável "
    s = s .. "'" .. var.v .. "' do tipo " .. var.tipo.basico
		erro(s, var.linha)
	elseif exp.tag == Tag.expNovoArray and var.tipo.tag ~= TipoTag.array then
			erro("variável " .. var.v .. " não é um array", exp.linha)
	elseif var.tipo.tag == TipoTag.array then
		local nvar = getVarDim(var, ambiente)
		if exp.tag == Tag.expNovoArray then
			if exp.dim > nvar then
				erro("tentativa de atribuir tipo incompatível para a variável '" .. var.v .. "'", var.linha)
			end
		elseif exp.tipo.tag == TipoTag.array then
			local nexp = getVarDim(exp, ambiente)
			if nvar ~= nexp then
				erro("tentativa de atribuir tipo incompatível para a variável '" .. var.v .. "'", var.linha)
			elseif nvar > 0 and var.tipo.basico ~= exp.tipo.basico then
				erro("tentativa de atribuir tipo incompatível para a variável '" .. var.v .. "'", var.linha)
			end
		elseif nvar > 0 then
			erro("tentativa de atribuir tipo incompatível para a variável '" .. var.v .. "'", var.linha)
		end
	end
end


local function analisaDecVar (decVar, ambiente)
	if decVar.exp then
		analisaAtrib(decVar, decVar.exp, ambiente)
	end
	--print("vou inserir")
	tabsim.insereSimbolo(decVar, ambiente)
end


local function analisaDecVarLista (listaDec, ambiente)
	for i, v in ipairs(listaDec) do
		analisaDecVar(v, ambiente)
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

local function analisaCmdChamada (c, ambiente)
	analisaExpChamada(c, ambiente)
end

local function analisaComando (c, ambiente)
	if c.tag == Tag.cmdAtrib then
		local var = tabsim.procuraSimbolo(c.p1, ambiente)
		local exp = c.p2
		if var ~= nil then
			c.p1.tipo = var.tipo
			--print("analisaComando", var.tipo.tag, var.tipo.dim, c.p1.tipo.dim)
			if var.tipo.tag == TipoTag.array and var.tipo.dim < c.p1.tipo.dim then
				erro("array '" .. c.p1.v .. "' possui somente " .. var.tipo.dim .. " dimensão(ões)", c.p1.linha)
			else
				--print("analisaComando ", var, var.v, var.tipo, c.p1, c.p1.tipo)
				analisaAtrib(c.p1, exp, ambiente)
			end
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
