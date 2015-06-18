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

function makeTeste (arquivos)
	for i, v in ipairs(arqTeste) do
		print(v.nome, v.nerro)
		local s = readFile(dir .. "/" .. v.nome)
		erro.inicia()
		local t, e = parser.parse2(s)
		assert(t ~= nil, "Erro foi no sintatico")
		--arvore.imprimeArvore(t)
		semantica.analisaPrograma(t)
		local terro = erro.getErros()
		assert(#terro == v.nerro, "Numero de erros = " .. #terro)
		for _, e in ipairs(terro) do
	  	print(e)
		end 
	end
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
novoTeste("erroPrecOpNao.por", 2)

makeTeste(arqTeste)
print("OK")

dir = "./test/semYes"
arqTeste = {}
for file in lfs.dir(dir) do
	if isValid(file) then
		novoTeste(file, 0)
	end
end


makeTeste(arqTeste)
print("OK Yes")

