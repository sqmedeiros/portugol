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
		--print("INSERE ", var.tipo, var.v, var.tipo.tag, var.tipo.basico)
		ambiente[n][nome] = { dim = dim, tipo = var.tipo }
		if valor then
			inicializaNovoArray(ambiente[n][nome], valor, ambiente, dim, t, 1)
		end
	else
		local nome = var.v
		ambiente[n][nome] = { v = valor, tipo = var.tipo }
	end
end

local function inicializaNovoArray (var, nexp, dim, t, i)
	if i > nexp then
		return
	else
		var.array = {}
		var.n = t[i]
		--print("Inicializa i = ", i, #t, t[i])
		if i < #t then
			for j = 1, var.n do
				var.array[j] = {}
				var.n = 0
				inicializaNovoArray(var.array[j], nexp, dim, t, i + 1)
			end
		else
			for j = 1, var.n do
				var.array[j] = {}
				var.array[j].v = -999
			end
		end
	end
end

local function getValor (exp, ambiente)
	local n = #ambiente
	local nome = exp.v 
	--print("getValor: nome = ", nome, idx, exp.tag, exp.tipo.tag)
	while n >= 1 do
		if ambiente[n][nome] then
			--print("tou aqui", ambiente[n][nome].tipo.tag, TipoTag.array)
			return ambiente[n][nome]
		end
		n = n - 1
	end

	erro("O símbolo '" .. nome .. "' nao foi declarado", exp.linha)
	return nil	
end

local function getValorArray (var, ambiente, idx)
	local t = 1 
end

local function setValor (var, valor, nexp)
	--print("setValor ", var, var.v, var.array, var.tipo, var.tipo.tag, valor, nexp)
	
	if var.tipo.tag == TipoTag.array then
		if nexp ~= nil then  -- novo array
			--print("INSERE setValor ", var.tipo.basico, valor[1])
			inicializaNovoArray(var, nexp, var.tipo.dim, valor, 1)
		else
			var.array = valor.array
			var.n = valor.n
		end
	else
		var.v = valor
	end
end

local function setValorSimples (var, valor)
	var.v = valor
end

return {
	criaAmbiente = criaAmbiente,
	entraBloco = entraBloco,
	saiBloco = saiBloco,
	insereSimbolo = insereSimbolo,
	getValor = getValor,
	setValor = setValor,
	setValorSimples = setValorSimples
}

