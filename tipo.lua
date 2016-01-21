local defs = require 'defs'
local tabsim = require 'tabsimbolos'
local arvore = require 'arvore'
local erro = require 'erro'

local TipoBasico = defs.TipoBasico
local TipoTag = defs.TipoTag
local Tag = defs.Tag

local tiposCompativies

local tabConversao = {}

tabConversao[TipoBasico.bool] = {
	[TipoBasico.bool] = true,
	[TipoBasico.inteiro] = false,
	[TipoBasico.numero] = false,
	[TipoBasico.texto] = false,
}

tabConversao[TipoBasico.inteiro] = {
	[TipoBasico.bool] = false,
	[TipoBasico.inteiro] = true,
	[TipoBasico.numero] = true,
	[TipoBasico.texto] = true,
}

tabConversao[TipoBasico.numero] = {
	[TipoBasico.bool] = false,
	[TipoBasico.inteiro] = true,
	[TipoBasico.numero] = true,
	[TipoBasico.texto] = true,
}

tabConversao[TipoBasico.texto] = {
	[TipoBasico.bool] = false,
	[TipoBasico.inteiro] = true,
	[TipoBasico.numero] = true,
	[TipoBasico.texto] = true,
}


local function temTipo (t)
	assert(t.tag ~= TipoTag.naotipado and t.basico ~= TipoBasico.naotipado)
end

function tiposCompativeis (t1, t2, atrib) -- t1 e t2 são tipos básicos
	if t1  == t2 then
		return true
	end
	
	-- conversão implícita somente de "inteiro" para "numero"
	if t1 == TipoBasico.numero and t2 == TipoBasico.inteiro then
		return true
	end
		
	-- nao pode atribuir um valor "numero" a um valor "inteiro"
	if not atrib and t1 == TipoBasico.inteiro and t2 == TipoBasico.numero then
		return true
	end

	return false
end

local function converteTipos (t1, t2)
	return tabConversao[t1][t2] 
end

local function naoTipado (t)
	return t.tag == TipoTag.naotipado or
         t.basico == TipoBasico.naotipado
end

return {
	naoTipado = naoTipado,
	tiposCompativeis = tiposCompativeis
}
