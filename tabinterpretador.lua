local erro = require 'erro'
local defs = require 'defs'
local tipo = require 'tipo'

erro = erro.erro
local Tag = defs.Tag
local TipoTag = defs.TipoTag
local TipoBasico = defs.TipoBasico

local function ehExpArray (exp)
	return exp.tag == Tag.expArray
end

local function criaAmbiente ()
	return {}
end

local function entraBloco (ambiente) 
	table.insert(ambiente, {})
end

local function saiBloco (ambiente)
	assert(#ambiente > 0) 
	table.remove(ambiente)	
end

local function insereSimbolo (var, valor, ambiente, dim, t)
	local n = #ambiente
	local dim = var.tipo.dim
	local nome = var.v
	if var.tag == Tag.decArrayVar then
		local nome = var.v
		print("INSERE ", var.tipo, var.v, var.tipo.tag, var.tipo.basico)
		ambiente[n][nome] = { dim = dim, tipo = var.tipo }
		if valor then
			inicializaNovoArray(ambiente[n][nome], valor, ambiente, dim, t, 1)
		end
	else
		local nome = var.v
		ambiente[n][nome] = { v = valor, tipo = var.tipo }
	end
end

local function inicializaArray (var, nexp, ambiente, dim, t, i)
	if i > nexp then
		return
	else
		var.array = {}
		var.n = t[i]
		if i < #t then
			for j = 1, var.n do
				var.array[j] = {}
				var.n = 0
				inicializaArray(var.array[j], nexp, ambiente, dim, t, i + 1)
			end
		end
	end
end

local function getValor (exp, ambiente, idx)
	local n = #ambiente
	local nome = exp.v 
	print("getValor: nome = ", nome, idx, exp.tag, exp.tipo.tag)
	while n >= 1 do
		if ambiente[n][nome] then
			print("tou aqui", ambiente[n][nome].tipo.tag, TipoTag.array)
			if ambiente[n][nome].tipo.tag == TipoTag.array then
				assert(nil, "ehAgora")
				return ambiente[n][nome][idx].v
			else
				return ambiente[n][nome].v
			end
		end
		n = n - 1
	end

	erro("O símbolo '" .. nome .. "' nao foi declarado", exp.linha)
	return nil	
end

local function getValorArray (var, ambiente, idx)
	local t = 1 
end

local function setValor (exp, valor, ambiente, idx)
	local n = #ambiente
	local nome = exp.v
	print("setValor ", nome, exp, exp.v, exp.v.v, idx)

	while n >= 1 do
		if ambiente[n][nome] then
			if ehExpArray(exp) then
				ambiente[n][nome][idx].v = valor
			else
				ambiente[n][nome].v = valor
			end
			return
		end
		n = n - 1
	end

	erro("O símbolo '" .. nome .. "' nao foi declarado", exp.linha) 
end

local function setValorArray ()

end

return {
	criaAmbiente = criaAmbiente,
	entraBloco = entraBloco,
	saiBloco = saiBloco,
	insereSimbolo = insereSimbolo,
	getValor = getValor,
	setValor = setValor
}

