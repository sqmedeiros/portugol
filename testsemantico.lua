local parser = require 'parser'
local lfs = require 'lfs'
local semantica = require 'semantica'
local arvore = require 'arvore'
local erro = require 'erro'

local function isValid (f) 
	if f == "." or f == ".." then
		return false
	end
	if string.match(f, "[.]swp") then
		return false
	end
	return true
end

local function readFile (name)
	local f = io.open(name)
	if not f then
		error("Erro ao tentar abrir " .. name)
	end
	local s = f:read("*a")
	f:close()
	return s
end


local dir = "./test/semNo"
local arqTeste = {}

local function novoTeste (nomeArq, nerro)
	table.insert(arqTeste, { nome = nomeArq, nerro = nerro })
end

novoTeste("decVar.por", 1)
novoTeste("erroRedeclaracao.por", 5)
novoTeste("erroNaoDec.por", 4)
novoTeste("conversaoTipoInt.por", 8)
novoTeste("conversaoTipoNum.por", 3)
novoTeste("conversaoTipoTexto.por", 4)
novoTeste("conversaoTipoBool.por", 3)
novoTeste("tipoOpNumExp.por", 10)
novoTeste("tipoOpBoolExp.por", 5)
novoTeste("tipoOpCompExp.por", 6)
novoTeste("tipoExpCmd.por", 7)
novoTeste("blocoVazio.por", 1)

for i, v in ipairs(arqTeste) do
	print(v.nome, v.nerro)
	local s = readFile(dir .. "/" .. v.nome)
	erro.inicia()
	local t, e = parser.parse2(s)
	assert(t ~= nil, "Erro foi no sintatico")
	--arvore.imprimeArvore(t)
	semantica.analisaPrograma(t)
	local terro = erro.getErros()
	--assert(#terro == v.nerro, "Numero de erros = " .. #terro)
	--for _, e in ipairs(terro) do
		--print(e)
	--end 
end
print("OK")

--[=[local dir = "./test/parserYes"

for file in lfs.dir(dir) do
	if isValid(file) then 
		local s = readFile(dir .. "/" .. file)
		assert(parser.parse(s) ~= nil)
	end
end
print("OK Yes")
]=]

