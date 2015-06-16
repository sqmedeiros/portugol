local defs = require 'defs'

local Tag = defs.Tag
local Tipo = defs.Tipo

local includes = [[
#include <iostream>
#include <string>

using std::cin;
using std::cout;
using std::endl;
using std::string;
]]

local mainInicio = [[
int main ()
]]


local mainFinal = [[
  return 0;
}
]]

local codigo = {}


local geraBloco

local function geraCodigo (s)
	table.insert(codigo, s)
end


local function geraCodigoLinha (s)
	geraCodigo(s .. '\n')
end

local function geraCodigoEspaco (s)
	geraCodigo(s .. ' ')
end


local function geraInicio ()
	table.insert(codigo, includes .. mainInicio)	
end

local function geraFinal ()
	table.insert(codigo, mainFinal)
end

local function geraTipo (t)
	if t == Tipo.inteiro then
		geraCodigoEspaco("int")
	elseif t == Tipo.numero then
		geraCodigoEspaco("double")
	elseif t == Tipo.texto then
		geraCodigoEspaco("string")
	elseif t == Tipo.bool then
		geraCodigoEspaco("bool") 
	end
end


local function geraCodigoVar (var)
	geraCodigoEspaco(var.v)
end

local function geraOpExp (exp)
	geraCodigoEspaco(exp.cod)
end

local function geraExp (exp)
	geraCodigo"("
	if exp.p1 and exp.p2 then
		geraExp(exp.p1)
		geraOpExp(exp.op)
		geraExp(exp.p2)	
	elseif exp.tag == Tag.expInt then
		geraCodigoEspaco(exp.v)
	elseif exp.tag == Tag.expNum then
		geraCodigoEspaco(exp.v)
	elseif exp.tag == Tag.expBool then
		geraCodigoEspaco(tostring(exp.v))
	elseif exp.tag == Tag.expTexto then
		geraCodigoEspaco('(string) "' .. exp.v .. '"')
	elseif exp.tag == Tag.expVar then
		geraCodigoVar(exp)
	elseif exp.tag == Tag.expNao then
		geraOpExp(exp.op)
		geraCodigoEspaco("(")
		geraExp(exp.exp)
		geraCodigoEspaco(")")
	else
		error("Expressao desconhecida2 " .. exp.tag)
	end
	geraCodigo")"
end


local function geraDecVar (v, listaDec)
	if not listaDec then
		geraTipo(v.tipo)
	end

	geraCodigoVar(v.var)
	if v.exp then
		geraCodigoEspaco("=")
		geraExp(v.exp)
	end
end

function geraChamada (c, ambiente)
	if c.nome.v == "saida" then
		geraCodigoEspaco('cout')
		for i, v in ipairs(c.args) do
			geraCodigoEspaco('<<')
			geraExp(v)
		end
		geraCodigoLinha('<< endl;')
	elseif c.nome.v == "entrada" then
		geraCodigoEspaco('cin')
		for i, v in ipairs(c.args) do
			geraCodigoEspaco('>>')
			geraExp(v)
		end
		geraCodigoLinha(';')
	else
		error("Função inválida")
	end
end

local function geraDecVarLista (dec)
	geraTipo(dec.tipo)
	for i, v in ipairs(dec.lista) do
		if (i > 1) then
			geraCodigoEspaco(",")
		end
		geraDecVar(v, true)
	end
	geraCodigoLinha(";")
end

local function geraComandoSe (c)
	geraCodigoEspaco("if (")
	geraExp(c.expSe)
	geraCodigoEspaco(")")
	geraBloco(c.blocoSe)
	
	if c.senaoSe then
		local lista = c.senaoSe.lista
		for i, v in ipairs(lista) do
			geraCodigoEspaco("else if (")
			geraExp(v.exp)
			geraCodigoEspaco(")")
			geraBloco(v.bloco)
		end
	end

	if c.senao then
		geraCodigoEspaco("else")
		geraBloco(c.senao)	
	end

end

local function geraComandoRepita (c)
	geraCodigoEspaco("while (")
	geraExp(c.exp)
	geraCodigoEspaco(")")
	geraBloco(c.bloco)
end

local function geraComando (c)
	if c.tag == Tag.cmdAtrib then
		geraCodigoEspaco(c.p1.v .. " =")
		geraExp(c.p2)
		geraCodigoLinha(";")
	elseif c.tag == Tag.cmdSe then
		geraComandoSe(c)
	elseif c.tag == Tag.cmdRepita then
		geraComandoRepita(c)
	elseif c.tag == Tag.cmdChamada then
		geraChamada(c)
	else
		error("Comando desconhecido")
	end
end

function geraBloco (bloco)
	geraCodigoLinha("{")
	
	for i, v in ipairs(bloco.tbloco) do
		if v.tag == Tag.decVarLista then
			geraDecVarLista(v)
		else -- eh comando
			geraComando(v)
		end	
	end
	
	geraCodigoLinha("}")	
end

local function geraPrograma (t) 
	geraInicio()
	if t.tag  == Tag.bloco then
		geraBloco(t)
		return table.concat(codigo)
	else
		erro("Estrutura inválida", t.linha)
	end
end

return {
	geraPrograma = geraPrograma,
}
