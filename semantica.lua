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
			if v.tipo.tag == TipoTag.array then -- verificar dimensoes do array
				--print("ehArray", v.dim) 
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

	local n1, n2 = 0, 0
	if p1.tipo.tag == TipoTag.array then
		local v1 = tabsim.procuraSimbolo(p1, ambiente)
		if v1 then
			n1 = v1.tipo.dim - p1.dim
		end
	end
	if p2.tipo.tag == TipoTag.array then
		local v2 = tabsim.procuraSimbolo(p2, ambiente)
		if v2 then
			n2 = v2.tipo.dim - p2.dim
		end	
	end
		
	if n1 ~= 0 or n2 ~= 0 then 
		erro("operandos inválidos para o operador binário'" .. exp.op.s .. "'", exp.linha)
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
		local idx = 0
		if var.t then
			idx = #var.t
		end
		if exp.tag == Tag.expNovoArray then
			--if var.tipo.basico ~= exp.tipo.basico then
				--local s = "não pode atribuir expressão do tipo " .. exp.tipo.basico .. " à variável "
    		--s = s .. "'" .. var.v .. "' do tipo " .. var.tipo.basico
				--erro(s, var.linha)
			--end
			if exp.dim > var.tipo.dim - idx then
				erro("tentativa de atribuir tipo incompatível para a variável '" .. var.v .. "'", var.linha)
			end
		elseif exp.tipo.tag == TipoTag.array then
			local aux = 0
			if exp.tipo.t then
				aux = #exp.tipo.t
			end
			if var.tipo.dim - idx ~= exp.tipo.dim - aux then
				erro("tentativa de atribuir tipo incompatível para a variável '" .. var.v .. "'", var.linha)
			elseif var.tipo.dim -idx > 0 and var.tipo.basico ~= exp.tipo.basico then
				erro("tentativa de atribuir tipo incompatível para a variável '" .. var.v .. "'", var.linha)
			end
		elseif var.tipo.dim - idx > 0 then
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


local function ehTamArrayValido (exp)
	if exp.tag == Tag.expInt then
		return true
	elseif exp.tag == Tag.expSimpVar then --TODO: mudar depois pra aceitar variaveis inicializadas
		return false
	elseif exp.tag == Tag.expOpNum then
		return ehTamArrayValido(exp.p1) and ehTamArrayValido(exp.p2)
	else
		return false
	end
end


local function analisaDecArrayVar (decArrayVar, ambiente)
	--print("chamei analisaDecArrayVar")
	--analisaExp(decArrayVar.tam, ambiente)
	
	--if tipo.naoTipado(decArrayVar.tam.tipo) then
	--	return
	--end	

	--print("DecArrayVar ", decArrayVar.tam.tipo.basico)
	--print("compat", tipo.tiposCompativeis(decArrayVar.tam.tipo.basico, TipoBasico.inteiro))
	-- TODO: ver onde uso tiposCompativeis e onde quero o próprio tipo
	--if not (decArrayVar.tam.tipo.basico == TipoBasico.inteiro) then
		--local s = "tamanho do array deve ser uma expressão do tipo inteiro"
		--erro(s, decArrayVar.tam.linha)
	--elseif not ehTamArrayValido(decArrayVar.tam) then
			--local s = "tamanho do array deve poder ser determinado em tempo de compilação"
	--		local s = "expressão que define o tamanho do array deve ser constantepoder ser determinado em tempo de compilação"
	--		erro(s, decArrayVar.tam.linha)
	--end

	--if decArrayVar.exp then  TODO: permitir inicializar o array na declaração
		--analisaTipoAtrib(decArrayVar.v, decArrayVar.exp, ambiente)
	--end
	tabsim.insereSimbolo(decArrayVar, ambiente, true)
end


local function analisaDecVarLista (listaDec, ambiente)
	for i, v in ipairs(listaDec) do
		--if v.tag == Tag.decArrayVar then
			--print("DecArrayVAR")
			--analisaDecArrayVar(v, ambiente)
		--else
			--print("DecVar vai")
			analisaDecVar(v, ambiente, true)
		--end
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
