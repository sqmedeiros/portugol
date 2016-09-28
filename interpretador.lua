local defs = require 'defs'
local tab = require 'tabinterpretador'
local unpack = table.unpack or unpack

local TipoTag = defs.TipoTag
local TipoBasico = defs.TipoBasico
local Tag = defs.Tag

local avaliaNovoArrayExp, avaliaExpChamada, decVar
local getVarArrayRef
local execBlocoFuncao
local valRetorno, auxRetorno, tagRetorno = nil, nil, nil
local flagRetorno = false 

local function avalia (exp, ambiente)
	assert(ambiente ~= nil)
	if exp.p1 and exp.p2 then
		local v1 = avalia(exp.p1, ambiente)
		local v2 = avalia(exp.p2, ambiente)
		if v1 == nil or v2 == nil then
			error("(Erro)Perto da linha " .. exp.linha .. ": operação inválida com expressão sem valor")
		end
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
			--print("opDiv", exp.p1.tag, exp.p1.tipo, exp.p1.tipo.basico)
			if exp.p1.tipo.basico == TipoBasico.inteiro and exp.p2.tipo.basico == TipoBasico.inteiro then 
				return v1 // v2
			else
				return v1 / v2
			end
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
	elseif exp.tag == Tag.expSimpVar then
		local var = tab.getValor(exp, ambiente)
		if var.array then
			return var
		else
			return var.v
		end
	elseif exp.tag == Tag.expNao then
		local v = avalia(exp.exp, ambiente)
		return not v
	elseif exp.tag == Tag.expNovoArray then
		return avaliaNovoArrayExp(exp, ambiente)
	elseif exp.tag == Tag.expArrayVar then
		local var = tab.getValor(exp, ambiente)
		--print("expArrayVar", var, var.v, var.tipo, var.tipo.tag, var.tipo.dim)
		local res = getVarArrayRef(var, 1, exp.t, ambiente, var.linha or exp.linha)
		--print("arrayVar2 res = ", res, res.v)
		return res.v  --TODO: ver o caso de "res" ser um array
	elseif exp.tag == Tag.expChamada then
		return avaliaExpChamada(exp, ambiente)
	else
		error("Expressao desconhecida3 " .. exp.tag)
	end
end

function avaliaNovoArrayExp (exp, ambiente)
	local res = {}
	--print("avaliaNovoArrayExp", exp.nexp, exp.dim)
	for i, v in ipairs(exp.v) do
		if v.ehExp then
			res[i] = avalia(v, ambiente)
		else
			break
		end
	end

	return exp.nexp, res
end

function avaliaExpChamadaAux (exp, ambiente)
	local t = {}
	for i, v in ipairs(exp.args) do
		local s = avalia(v, ambiente)
		if s == nil then
			error("Variável " .. v.v .. " não foi inicializada")
		end
		t[#t + 1] = s
	end

	local f = tab.getValor(exp.nome, ambiente)
	local params = f.params

	tab.entraBloco(ambiente)

	for i, v in ipairs(params.lista) do
		if v.tag == Tag.decVar then
			decVar(v, ambiente, t[i])
		elseif v.tag == Tag.decArrayVar then
			tab.insereSimbolo(v, nil, ambiente, v.tipo.dim)
			local ref = tab.getValor(v, ambiente)
			tab.setValor(ref, t[i])	
		else
			error("Desconhecido")
		end
	end
	
	execBlocoFuncao(f.tbloco, ambiente) --atualiza 'valRetorno'
	tab.saiBloco(ambiente)
	return valRetorno, auxRetorno
end

local function mytostring(v)
	if v == true then
		return "verdadeiro"
	elseif v == false then
		return "falso"
	else
		return tostring(v)
	end
end


function avaliaExpChamada (exp, ambiente)
	if exp.nome.v == "escreva" then
		for i, v in ipairs(exp.args) do
			local e1 = avalia(v, ambiente)
			local s1 = mytostring(e1)
			io.write(s1, " ")
		end
		io.write("\n")
	elseif exp.nome.v == "leia" then
		for i, v in ipairs(exp.args) do
			local x
			--print("vartipo", v.tipo, v.v, v.tag)
			if v.tipo.basico == TipoBasico.inteiro or v.tipo.basico == TipoBasico.numero then
				x = io.read("*n")
				x = tonumber(x)
			else
				x = io.read("l")
			end
			if not x then
				error("(Erro) Perto da linha " .. exp.nome.linha .. ": erro ao ler '" .. v.v .. "'") 
			end
			local ref = tab.getValor(v, ambiente)
			if v.tipo.tag == TipoTag.array then
				ref = getVarArrayRef(ref, 1, v.t, ambiente, v.linha)
			end
			tab.setValor(ref, x)
		end
	elseif exp.nome.v == "textoComp" then
		local v = exp.args[1]
		local s = avalia(v, ambiente)
		if s == nil then
			error("Variável " .. v.v .. " não foi inicializada")
		end
		return #s
	elseif exp.nome.v == "textoSub" then
		local t = {}
		for i, v in ipairs(exp.args) do
			local s = avalia(v, ambiente)
			if s == nil then
				error("Variável " .. v.v .. " não foi inicializada")
			end
			t[#t + 1] = s
		end
		return string.sub(unpack(t))
	elseif exp.nome.v == "textoPos" then
		exp.nome.v = "textoSub"
		exp.args[3] = exp.args[2]
		return avaliaExpChamada(exp, ambiente)
	elseif exp.nome.v == "converteInt" then
		local v = exp.args[1]
		local s = avalia(v, ambiente)
		return math.tointeger(s)
	else
		return avaliaExpChamadaAux(exp, ambiente)
	end			
end

function getVarArrayRef (v, i, t, ambiente, linha)
	--print("arrayRef", v, i, t)
	if t == nil then
		return v
	end

	x = avalia(t[i], ambiente)	
	--print("ref21 ", v, x, v[x], #t, t[i], v.array, v.n, v.v)
	--print("ref2 ",  v.array[x])

	if v.n == nil then
		error("(Erro) Perto da linha " .. linha .. " array não inicializado")
	elseif x > v.n then
		error("(Erro) Perto da linha " .. linha .. " acesso a índice inválido " .. x .. " do array")
	end

	if i == #t then
		return v.array[x]		
	end
	
	return getVarArrayRef(v.array[x], i + 1, t, ambiente, linha)
end

local function decArrayVar (v, ambiente)
	if not v.exp then
		tab.insereSimbolo(v, nil, ambiente, v.tipo.dim)	
	else
		if v.exp.tag == Tag.expChamada then
			local nexp, t = avalia(v.exp, ambiente)
			if tagRetorno == Tag.expNovoArray then
				tab.insereSimbolo(v, nexp, ambiente, v.tipo.dim, t)
			else
				tab.insereSimbolo(v, nil, ambiente, v.tipo.dim)
				local ref = tab.getValor(v, ambiente)
				tab.setValor(ref, nexp)	
			end	 
		elseif v.exp.tag == Tag.expNovoArray then 
			local nexp, t = avalia(v.exp, ambiente)
			tab.insereSimbolo(v, nexp, ambiente, v.tipo.dim, t)
		elseif v.exp.tag == Tag.expSimpVar or v.exp.tag == Tag.expArrayVar then
			tab.insereSimbolo(v, nil, ambiente, v.tipo.dim)
			local ref = tab.getValor(v, ambiente)
			local x = avalia(v.exp, ambiente)
			tab.setValor(ref, x)	
		else --??
			error("decArrayVar: inicialiação não implementada")
		end
	end
end

function decVar (v, ambiente, aux)
	local exp
	if v.exp then
		exp = avalia(v.exp, ambiente)
	elseif aux then
		exp = aux
	end
	tab.insereSimbolo(v, exp, ambiente) 
end

function execChamada (c, ambiente)
	avaliaExpChamada(c, ambiente)
end

local function decVarLista (dec, ambiente)
	for i, v in ipairs(dec.lista) do
		if v.tag == Tag.decVar then
			decVar(v, ambiente)
		else
			decArrayVar(v, ambiente)
		end
	end
end

local function decFuncao (decf, ambiente)
	tab.insereSimbolo(decf, nil, ambiente)
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
	while exp and not flagRetorno do
		execBloco(c.bloco, ambiente)
		exp = avalia(c.exp, ambiente)
	end
end

local function execCmdAtrib (c, ambiente)		
	local var = c.p1
	local ref = tab.getValor(var, ambiente)
	if var.tipo.tag == TipoTag.array then
		--print("vou pegar ref", var.v, var.dim, ref, ref.array, ref.v)
		if var.t ~= nil then
			--print("embaixo", var.t, #var.t, var.linha)
		end
		ref = getVarArrayRef(ref, 1, var.t, ambiente, var.linha)
		--ref.tipo = {}
		--ref.tipo.dim = var.tim
		--if var.t ~= nil then
			--ref.tipo.dim = var.dim - #var.t
			--print("ref.tipo.dim", var.dim, ref.tipo.dim)
		--end
	end

	if c.p2.tag == Tag.expNovoArray then
		local nexp, t = avalia(c.p2, ambiente)
		ref.tipo = {}
		--ref.tipo.dim = var.tipo.dim 	
		--print("cmdAtrib", ref, ref.array, ref.v, nexp, t, t[1], ref.tipo, ref.tipo.dim)
		tab.setValor(ref, t, nexp)
	else
		local v = avalia(c.p2, ambiente)
		--print("eu", v, c.p2, c.p2.tag)
		tab.setValor(ref, v)
	end
end

local function execCmd (c, ambiente)
	if c.tag == Tag.cmdAtrib then
		execCmdAtrib(c, ambiente)
	elseif c.tag == Tag.cmdSe then
		execCmdSe(c, ambiente)
	elseif c.tag == Tag.cmdRepita then
		execCmdRepita(c, ambiente)
	elseif c.tag == Tag.cmdChamada then
		execChamada(c, ambiente)
	elseif c.tag == Tag.cmdRetorne then
		valRetorno, auxRetorno = avalia(c.exp, ambiente)
		tagRetorno = c.exp.tag
    flagRetorno = true
	else
		error("Comando desconhecido")
	end
end

function execBlocoFuncao (bloco, ambiente)
	for i, v in ipairs(bloco.tbloco) do
		if v.tag == Tag.decVarLista then
			decVarLista(v, ambiente)
		else -- eh comando
			execCmd(v, ambiente)
      if flagRetorno then
				flagRetorno = false
				return
			end
		end	
	end
end


function execBloco (bloco, ambiente)
	tab.entraBloco(ambiente)

	for i, v in ipairs(bloco.tbloco) do
		if v.tag == Tag.decVarLista then
			decVarLista(v, ambiente)
		elseif v.tag == Tag.decFuncao then
			decFuncao(v, ambiente)
		else -- eh comando
			execCmd(v, ambiente)
      if flagRetorno then
				tab.saiBloco(ambiente)
				return
			end
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
