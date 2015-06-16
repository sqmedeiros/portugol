local tabErros

local function inicia ()
	tabErros = {}
end

local function erro (msg, linha)
	assert(msg and linha)
	local s = "Erro perto da linha " .. linha .. ": " .. msg
	table.insert(tabErros, s)
end

local function getErros ()
	return tabErros
end

return {
	inicia = inicia,
	erro = erro,
	getErros = getErros	
}
