local erro = require 'erro'

erro = erro.erro

local idxGlobal = 1

local ambiente

local tglobal = { 
	["entrada"] = {},
  ["saida"] = {}
}

local function criaAmbiente (g)
	ambiente = {}
	local g = g or tglobal
	table.insert(ambiente, tglobal)
  return ambiente
end

local function entraBloco (ambiente) 
	table.insert(ambiente, {})
end

local function saiBloco (ambiente)
	assert(#ambiente > 1) -- ver depois o ambiente global
	table.remove(ambiente)	
end

local function getAmbienteGlobal ()
	return ambiente[idxGlobal]
end

local function insereSimbolo (simbolo, ambiente)
	local n = #ambiente
	local nome = simbolo.v
	if ambiente[n][nome] then
		erro("O símbolo '" .. nome .. "' jah foi declarado nesse escopo", simbolo.linha) 
	else
		ambiente[n][nome] = simbolo
	end
end

local function procuraSimbolo (simbolo, ambiente)
	local n = #ambiente
	local nome = simbolo.v
	while n >= 1 do
		if ambiente[n][nome] then
			return ambiente[n][nome]
		end
		n = n - 1
	end

	erro("O símbolo '" .. nome .. "' nao foi declarado", simbolo.linha) 
	return nil	
end

return {
	criaAmbiente = criaAmbiente,
	entraBloco = entraBloco,
	saiBloco = saiBloco,
	insereSimbolo = insereSimbolo,
	procuraSimbolo = procuraSimbolo
}

