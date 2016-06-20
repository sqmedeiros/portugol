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

local function insereSimbolo (simbolo, ambiente, ehArray)
	local n = #ambiente
	local nome = simbolo.v
	--print("insere tipo = ", nome)
	--print("insere tipo = ", simbolo.tipo, simbolo.tipo.basico, simbolo.tipo.tag)
	if ambiente[n][nome] then
		erro("o símbolo '" .. nome .. "' jah foi declarado nesse escopo", simbolo.linha) 
	else
		ambiente[n][nome] = { v = nome, tipo = simbolo.tipo, ehArray = ehArray }
	end
end

local function procuraSimbolo (simbolo, ambiente)
	local n = #ambiente
	local nome = simbolo.v
	--print("procuraSimbolo", nome, simbolo.v)
	while n >= 1 do
		if ambiente[n][nome] then
			return ambiente[n][nome]
		end
		n = n - 1
	end

	erro("o símbolo '" .. nome .. "' nao foi declarado", simbolo.linha) 
	return nil	
end

return {
	criaAmbiente = criaAmbiente,
	entraBloco = entraBloco,
	saiBloco = saiBloco,
	insereSimbolo = insereSimbolo,
	procuraSimbolo = procuraSimbolo
}

