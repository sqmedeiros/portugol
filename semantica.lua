local defs = require 'defs'
local tabsim = require 'tabsimbolos'
local arvore = require 'arvore'
local tipo = require 'tipo'
local erro = require 'erro'

erro = erro.erro

local Tipo = defs.Tipo
local Tag = defs.Tag

local analisaBloco

local function analisaTipoAtrib (var, exp, ambiente)
	local tipoExp = tipo.getTipo(exp, ambiente)
	if tipoExp == Tipo.naotipado then
		return
	end
	if not tipo.tiposCompativeis(var.tipo, tipoExp, true) then
		local s = "Nao pode atribuir expressao do tipo " .. tipoExp .. " à variável "
    s = s .. "'" .. var.v .. "' do tipo " .. var.tipo
		erro(s, var.linha)
	end
end

local function analisaDecVar (decVar, ambiente)
	if decVar.exp then
		analisaTipoAtrib(decVar.var, decVar.exp, ambiente)
	end
	tabsim.insereSimbolo(decVar.var, ambiente)
end

local function analisaDecVarLista (listaDec, ambiente)
	for i, v in ipairs(listaDec) do
		analisaDecVar(v, ambiente)
	end
end

local function analisaExpCmd (exp, ambiente)
	local tipoExp = tipo.getTipo(exp, ambiente)

	if tipoExp ~= tipo.naotipado and not tipo.tiposCompativeis(tipoExp, Tipo.bool) then
		local s = "Expressao do 'se' deve ser booleana"
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
			local t = tipo.getTipo(v, ambiente)
		end	
	elseif c.nome.v == "entrada" then
		for i, v in ipairs(c.args) do
			local t = tipo.getTipo(v, ambiente)
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
			analisaTipoAtrib(c.p1, exp, ambiente)
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
