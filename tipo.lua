local defs = require 'defs'
local tabsim = require 'tabsimbolos'
local arvore = require 'arvore'
local erro = require 'erro'

local Tipo = defs.Tipo
local Tag = defs.Tag

local getTipo, getTipoExp, tiposCompativies
local getTipoOpNumExp, getTipoOpCompExp, getTipoOpBoolExp

local tabConversao = {}

tabConversao[Tipo.bool] = {
	[Tipo.bool] = true,
	[Tipo.inteiro] = false,
	[Tipo.numero] = false,
	[Tipo.texto] = false,
}

tabConversao[Tipo.inteiro] = {
	[Tipo.bool] = false,
	[Tipo.inteiro] = true,
	[Tipo.numero] = true,
	[Tipo.texto] = true,
}

tabConversao[Tipo.numero] = {
	[Tipo.bool] = false,
	[Tipo.inteiro] = true,
	[Tipo.numero] = true,
	[Tipo.texto] = true,
}

tabConversao[Tipo.texto] = {
	[Tipo.bool] = false,
	[Tipo.inteiro] = true,
	[Tipo.numero] = true,
	[Tipo.texto] = true,
}


function getTipoOpCompExp (exp1, exp2, ambiente)
	local t1 = getTipo(exp1, ambiente)
	local t2 = getTipo(exp2, ambiente)
	
	if t1 ~= Tipo.naotipado and t2 ~= Tipo.naotipado then
		if not tiposCompativeis(t1, t2) then
			local s = "Não é possível comparar uma expressão do tipo " .. t1
      s = s .. " com uma expressão do tipo " .. t2
			erro.erro(s, exp1.linha)
			return Tipo.naotipado
		end
	end

	return Tipo.bool
end


function getTipoOpBoolExp (op, exp1, exp2, ambiente)
	local t1 = getTipo(exp1, ambiente)
	local t2 = getTipo(exp2, ambiente)

	if t1 ~= Tipo.naotipado and t2 ~= Tipo.naotipado then
		if not tiposCompativeis(t1, Tipo.bool) or not tiposCompativeis(t2, Tipo.bool) then
			local s = "Expressões do '" .. op.s .. "' devem ser do tipo booleano"
			erro.erro(s, exp1.linha)
			return Tipo.naotipado
		end
		
	end

	return Tipo.bool
end


function getTipoExp (exp, ambiente)
	assert(ambiente, "Ambiente nulo")

  -- expBool, expInt, expNum, expTexto
	if exp.tipo ~= Tipo.naotipado then
		return exp.tipo
	end

	local tag = exp.tag
	if tag == Tag.expNao then
		local tipo = getTipo(exp.exp, ambiente)
		if tipo ~= Tipo.bool then
			erro.erro("expressao do '" .. exp.op.s .. "' deve ser do tipo booleano", exp.exp.linha)
			return Tipo.naotipado
		end
		return tipo
	elseif tag == Tag.expVar then
		local v = tabsim.procuraSimbolo(exp, ambiente)
		if v ~= nil then
			exp.tipo = v.tipo 
			return v.tipo
		else
			return Tipo.naotipado
		end
	elseif tag == Tag.expChamada then
		error("Falta tipar chamada de função")
	else
		local exp1 = exp.p1
		local exp2 = exp.p2
		if tag == Tag.opNumExp then
			return getTipoOpNumExp(exp, ambiente)
		elseif tag == Tag.opCompExp then
			return getTipoOpCompExp(exp1, exp2, ambiente)
		elseif tag == Tag.opBoolExp then
			return getTipoOpBoolExp(exp.op, exp1, exp2, ambiente) 
		else
			error("Expressao desconhecida " .. exp.tag)	
		end
	end
end

function getTipo (no, ambiente)
	assert(ambiente, "Ambiente nulo")
	if arvore.ehComando(no) then
		return Tipo.vazio
	elseif arvore.ehExpressao(no) then
		return getTipoExp(no, ambiente)
	else
		local tag = (no and no.tag) or ""
		error("Nao sei o tipo " .. tag)
	end
end


function getTipoOpNumExp (exp, ambiente)
	local t1 = getTipo(exp.p1, ambiente)
	local t2 = getTipo(exp.p2, ambiente)

	if t1 == Tipo.naotipado or t2 == Tipo.naotipado then
		return Tipo.naotipado
	end
		
	if tiposCompativeis(t1, Tipo.numero) and tiposCompativeis(t2, Tipo.numero) then
		if exp.op.op == "opMod" then
			if t1 ~= Tipo.inteiro or t2 ~= Tipo.inteiro then
				local s = "Os operandos de '" .. exp.op.s .. "' devem ser do tipo inteiro"
				erro.erro(s, exp.linha)
				return Tipo.naotipado
			else
				return Tipo.inteiro
			end
		elseif t1 == Tipo.numero or t2 == Tipo.numero then
			return Tipo.numero
		else
			return Tipo.inteiro	
		end
	end

	if tiposCompativeis(t1, Tipo.texto) and tiposCompativeis(t2, Tipo.texto) then
		if exp.op.op == "opSoma" then
			return Tipo.texto	
		end
	end

	local s = "Não é possível realizar a operação " .. exp.op.s .. " com uma expressão do tipo " .. t1
  s = s .. " e uma expressão do tipo " .. t2
	erro.erro(s, exp.linha)
	return Tipo.naotipado
end

function tiposCompativeis (t1, t2, atrib)
	if t1 == t2 then
		return true
	end
	
	-- conversão implícita somente de "inteiro" para "numero"
	if t1 == Tipo.numero and t2 == Tipo.inteiro then
		return true
	end
		
	-- nao pode atribuir um valor "numero" a um valor "inteiro"
	if not atrib and t1 == Tipo.inteiro and t2 == Tipo.numero then
		return true
	end

	return false
end

local function converteTipos (t1, t2)
	if tabConversao[t1][t2] then
		return true
	end
	return false	
end

return {
	getTipo = getTipo,
	tiposCompativeis = tiposCompativeis
}
