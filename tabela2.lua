local erro = require 'erro'

erro = erro.erro

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

local function insereSimbolo (nome, valor, ambiente)
	local n = #ambiente
	ambiente[n][nome] = { v = valor }
end

local function getValor (nome, ambiente)
	local n = #ambiente
	while n >= 1 do
		if ambiente[n][nome] then
			return ambiente[n][nome].v
		end
		n = n - 1
	end

	erro("O símbolo '" .. nome .. "' nao foi declarado") 
	return nil	
end

local function setValor (nome, valor, ambiente)
	local n = #ambiente
	while n >= 1 do
		if ambiente[n][nome] then
			ambiente[n][nome].v = valor
			return
		end
		n = n - 1
	end

	erro("O símbolo '" .. nome .. "' nao foi declarado") 
end


return {
	criaAmbiente = criaAmbiente,
	entraBloco = entraBloco,
	saiBloco = saiBloco,
	insereSimbolo = insereSimbolo,
	getValor = getValor,
	setValor = setValor
}

