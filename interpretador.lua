local defs = require 'defs'
local tab = require 'tabela2'

local Tag = defs.Tag
local Tipo = defs.Tipo

local function avalia (exp, ambiente)
	assert(ambiente ~= nil)
	if exp.p1 and exp.p2 then
		local v1 = avalia(exp.p1, ambiente)
		local v2 = avalia(exp.p2, ambiente)
		local op = exp.op.op
		if op == "opSoma" then
			if type(v1) == "string" then
				return v1 .. v2
			else
				return v1 + v2
			end
		elseif op == "opSub" then
			return v1 - v2
		elseif op == "opMult" then
			return v1 * v2
		elseif op == "opDiv" then
			return v1 / v2
		elseif op == "opMod" then
			return v1 % v2
		elseif op == "opMaiorIg" then
			return v1 >= v2
		elseif op == "opMaior" then
			return v1 > v2
		elseif op == "opMenorIg" then
			return v1 <= v2
		elseif op == "opMenor" then
			return v1 < v2
		elseif op == "opIgual" then
			return v1 == v2
		elseif op == "opE" then
			return v1 and v2
		elseif op == "opOu" then
			return v1 or v2
		elseif op == "opDif" then
			--print(v1, v2, type(v1), type(v2))
			return v1 ~= v2
		else
			error("Expressao desconhecida ", op)
		end
	elseif exp.tag == Tag.expInt then
		return exp.v
	elseif exp.tag == Tag.expNum then
		return exp.v
	elseif exp.tag == Tag.expBool then
		return exp.v
	elseif exp.tag == Tag.expTexto then
		return exp.v
	elseif exp.tag == Tag.expVar then
		return tab.getValor(exp.v, ambiente)
	elseif exp.tag == Tag.expNao then
		local v = avalia(exp.exp, ambiente)
		return not v
	else
		error("Expressao desconhecida3 " .. exp.tag)
	end
end


local function decVar (v, ambiente)
	local exp
	if v.exp then
		exp = avalia(v.exp, ambiente)
	end
	tab.insereSimbolo(v.var.v, exp, ambiente) 
end

function execChamada (c, ambiente)
	if c.nome.v == "saida" then
		for i, v in ipairs(c.args) do
			local exp = avalia(v, ambiente)
			io.write(tostring(exp), " ")
		end
		io.write("\n")
	elseif c.nome.v == "entrada" then
		for i, v in ipairs(c.args) do
			local x
			repeat
				--print("vartipo", v.tipo, v.v, v.tag)
				if v.tipo == Tipo.inteiro or v.tipo == Tipo.numero then
					x = io.read("*n")
					x = tonumber(x)
				else
					x = io.read()
				end
				
				--print("x = ", x, x == nil)
			until  true == true --x ~= nil
			tab.setValor(v.v, x, ambiente)
		end
	else
		error("Função inválida")
	end
end

local function decVarLista (dec, ambiente)
	for i, v in ipairs(dec.lista) do
		decVar(v, ambiente)
	end
end

local function execCmdSe (c, ambiente)
	local exp = avalia(c.expSe, ambiente)
	
	if exp then
		execBloco(c.blocoSe, ambiente)
		return
	end
	
	if c.senaoSe then
		local lista = c.senaoSe.lista
		for i, v in ipairs(lista) do
			exp = avalia(v.exp, ambiente)
			if exp then
				execBloco(v.bloco, ambiente)
				return
			end
		end
	end

	if c.senao then
		execBloco(c.senao, ambiente)	
	end

end

local function execCmdRepita (c, ambiente)
	local exp = avalia(c.exp, ambiente)
	while exp do
		execBloco(c.bloco, ambiente)
		exp = avalia(c.exp, ambiente)
	end
end

local function execCmd (c, ambiente)
	if c.tag == Tag.cmdAtrib then
		local v = avalia(c.p2, ambiente)
		tab.setValor(c.p1.v, v, ambiente)
	elseif c.tag == Tag.cmdSe then
		execCmdSe(c, ambiente)
	elseif c.tag == Tag.cmdRepita then
		execCmdRepita(c, ambiente)
	elseif c.tag == Tag.cmdChamada then
		execChamada(c, ambiente)
	else
		error("Comando desconhecido")
	end
end

function execBloco (bloco, ambiente)
	tab.entraBloco(ambiente)

	for i, v in ipairs(bloco.tbloco) do
		if v.tag == Tag.decVarLista then
			decVarLista(v, ambiente)
		else -- eh comando
			execCmd(v, ambiente)
		end	
	end

	tab.saiBloco(ambiente)	
end

local function executa (t)
	if t.tag  == Tag.bloco then
		execBloco(t, tab.criaAmbiente())	
	else
		erro("Estrutura inválida", t.linha)
	end
end


return {
	executa = executa,
}
