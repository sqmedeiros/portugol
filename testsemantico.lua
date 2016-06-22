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
	if string.sub(f, #f-3) == ".por" then
		return true
	end
	return false
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

local function equalString (s1, s2)
	s1 = string.gsub(s1, "[ \t]", "")
	s2 = string.gsub(s2, "[ \t]", "")
	return s1 == s2
end

local arqTeste = {}

local function novoTeste (nomeArq, nerro)
	table.insert(arqTeste, { nome = nomeArq, nerro = nerro })
end

function execFile (nome, dir)
	--executa arquivo portugol
	local nome = string.sub(nome, 1, #nome - 4)
	local prefixo = dir .. "/" .. nome
	local cmd = "lua main2.lua " .. prefixo .. ".por"
	local inCmd = ""
	if io.open(prefixo .. ".in") then -- arquivo de entrada associado
		inCmd = " < " .. prefixo .. ".in "
	end
	cmd = cmd .. inCmd.. " > " .. prefixo .. ".out"
	os.execute(cmd)
	
	--executa arquivo Lua equivalente
	local cmd2 = "lua " .. prefixo .. ".lua" .. inCmd .. " > " .. prefixo .. ".out2"
	os.execute(cmd2)

	local s1 = prefixo .. ".out"
	local f1 = readFile(s1)

	local s2 = prefixo .. ".out2"
	local f2 = readFile(s2)
	if not equalString(f1, f2) then
		error("Erro: arquivos de saída diferentes " .. nome)
	end
end

function makeTeste (arquivos, dir)
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
		if #terro == 0 then
			execFile(v.nome, dir)
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
novoTeste("erroPrecOpNao.por", 4) -- antes era 2, mas acho que 4 faz mais sentido
                                  -- erro ao aplicar "nao" a um inteiro, e erro
                                  -- de comparar um valor bool com um inteiro
novoTeste("erroArrayDec.por", 4)
novoTeste("erroArray1.por", 6)
novoTeste("erroArrayOpBin.por", 9)

local dir = "./test/semNo"
makeTeste(arqTeste, dir)
print("OK")

dir = "./test/semYes"
arqTeste = {}
for file in lfs.dir(dir) do
	if isValid(file) then
		novoTeste(file, 0)
	end
end

makeTeste(arqTeste, dir)
print("OK Yes")


dir = "./test/semYesArray"
arqTeste = {}
for file in lfs.dir(dir) do
	if isValid(file) then
		novoTeste(file, 0)
	end
end

makeTeste(arqTeste, dir)
print("OK YesArray")

