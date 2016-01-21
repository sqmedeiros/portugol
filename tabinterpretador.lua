local erro = require 'erro'
local defs = require 'defs'

erro = erro.erro
local Tag = defs.Tag

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

local function insereSimbolo (var, valor, ambiente)
	local n = #ambiente
	--print("valor = ", valor)
	local nome = var.v
	if var.tag == Tag.decArrayVar then
		local nome = var.v
		--print("insere Array nome = ", nome)
		ambiente[n][nome] = {}
		for i = 1, valor do
			ambiente[n][nome][i] =  { }
		end
	else
		local nome = var.v
		ambiente[n][nome] = { v = valor }
	end
end

local function getValor (exp, ambiente, idx)
	local n = #ambiente
	local nome = exp.v 
	--print("getValor: nome = ", nome, idx)	
	while n >= 1 do
		if ambiente[n][nome] then
			if ehExpArray(exp) then
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

local function setValor (exp, valor, ambiente, idx)
	local n = #ambiente
	local nome = exp.v
	--print("setValor ", nome, exp, exp.v, idx)

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


return {
	criaAmbiente = criaAmbiente,
	entraBloco = entraBloco,
	saiBloco = saiBloco,
	insereSimbolo = insereSimbolo,
	getValor = getValor,
	setValor = setValor
}

