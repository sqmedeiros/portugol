local defs = require 'defs'

local TipoTag = defs.TipoTag
local TipoBasico = defs.TipoBasico
local Tag = defs.Tag

local function imprimeEspaco(n)
	for i = 1, n do
		io.write(" ")
	end
end

local function msgLinha (l)
	return "linha = " .. l
end

local function imprimeArvore (t, tab, n)
	tab = tab or 0
  n = n or 2
	imprimeEspaco(tab)
	if t.tag == Tag.decVar then
    print(t.tag, t.tipo, msgLinha(t.linha))
		imprimeArvore(t.v, tab + n)
    if (t.exp) then
    	imprimeArvore(t.exp, tab + n)
		end
	elseif t.tag == Tag.decArrayVar then
		print(t.tag, t.tipo, msgLinha(t.linha))
		imprimeArvore(t.v, tab + n)
		imprimeArvore(t.tam, tab + n)
    if (t.exp) then
    	imprimeArvore(t.exp, tab + n)
		end
	elseif t.v ~= nil then
		print(t.tag, t.tipo, t.v, msgLinha(t.linha))
	elseif t.p1 and t.p2 then
		print(t.tag, t.tipo, msgLinha(t.linha))
		imprimeArvore(t.p1, tab + n)
		imprimeArvore(t.p2, tab + n)
	elseif t.tag == Tag.decVarLista then
		print(t.tag, t.tipo, msgLinha(t.linha))
		for i, v in ipairs(t.lista) do
			imprimeArvore(v, tab + n)
		end
  elseif t.tag == Tag.bloco then
    print(t.tag, msgLinha(t.linha))
		for i, v in ipairs(t.tbloco) do
			imprimeArvore(v, tab + n)
		end
	elseif t.tag == Tag.cmdSe then
		print(t.tag, msgLinha(t.linha))
		imprimeArvore(t.expSe, tab + n)
    imprimeArvore(t.blocoSe, tab + n)
		if t.senaoSe then
			imprimeArvore(t.senaoSe, tab + n)
		end
		if t.senao then
			imprimeEspaco(tab + n)
    	print("parte senao")
			imprimeArvore(t.senao, tab + n)
		end
	elseif t.tag == Tag.blocoSenaoSe then
    print"parteSenaoSe"
		for i, v in ipairs(t.lista) do
			imprimeArvore(v.exp, tab + n)
      imprimeArvore(v.bloco, tab + n)
		end
	elseif t.tag == Tag.cmdRepita then
		print(t.tag, msgLinha(t.linha))
		imprimeArvore(t.exp, tab + n)
		imprimeArvore(t.bloco, tab + n)	
  elseif t.tag == Tag.cmdChamada or t.tag == Tag.expChamada then
		print("vamos q vamos", t.tag)
		print(t.tag, t.tipo, t.nome.v, msgLinha(t.linha))
		for i, v in ipairs(t.args) do
			imprimeArvore(v, tab + n)
		end
	elseif t.tag == Tag.expNao then
		print(t.tag, t.tipo, msgLinha(t.linha))
		imprimeArvore(t.exp)
	else
    print(t, t.tag, type(t), t.p1, t.p2, t == "")
		assert(0 == 1, "Falta tratar", t)
	end
end

local function makeTipo (tipoTag, tipoBasico, dim)
	return { tag = tipoTag, basico = tipoBasico, dim = dim, linha = defs.linha }
end

local function makeNoV (tagNo, tipoTag, tipoBasico, v, dim, t)
  --print("noV", tagNo, tipoTag, tipoBasico, v, dim, t)
	assert(tagNo ~= nil and tipoTag ~= nil and tipoBasico ~= nil, tag, tipo)
	--print("makeNoV", v, defs.linha)
	return { tag = tagNo, tipo = makeTipo(tipoTag, tipoBasico),
           v = v, linha = defs.linha, ehExp = true, dim = dim, t = t }
end

local function makeNoOpBin (tag, tipo, op, p1, p2)
	assert(tag ~= nil and tipo ~= nil, tag, tipo)
	return { tag = tag, tipo = tipo, ehExp = true,
					 op = op, p1 = p1, p2 = p2, linha = defs.linha }
end

local function makeNoCmd (tag, v, exp)
	assert(tag ~= nil, tag)
	return { tag = tag, p1 = v, p2 = exp, linha = defs.linha }
end

local function noInteiro (v)
	return makeNoV(Tag.expInt, TipoTag.simples, TipoBasico.inteiro, tonumber(v)) 
end

local function noReal (v)
	return makeNoV(Tag.expNum, TipoTag.simples, TipoBasico.numero, tonumber(v))
end

local function noTexto (v)
	return makeNoV(Tag.expTexto, TipoTag.simples, TipoBasico.texto, v)
end

local function noBoolFalso ()
	return makeNoV(Tag.expBool, TipoTag.simples, TipoBasico.bool, false) 
end

local function noBoolVerd ()
	return makeNoV(Tag.expBool, TipoTag.simples, TipoBasico.bool, true) 
end

local function noTipo (tipoBase, ...)
	local n = #{...}
	--print("tipoBase ", tipoBase, #{...})
	if n == 0 then -- tipo simples
		return makeTipo(TipoTag.simples, tipoBase)
	else  -- tipo array
		return makeTipo(TipoTag.array, tipoBase, n)
	end
end

local function noId (v)
	--print("ID", Tag.expSimpVar, TipoTag.naotipado, TipoBasico.naotipado, v)
	return makeNoV(Tag.expSimpVar, TipoTag.naotipado, TipoBasico.naotipado, v)
end

local function noVar (v, ...)
	local l = { ... }
	local n = #l
	--print("noVar ", v, v.v, #l)
	if n > 0 then
		for i, v in ipairs(l) do
			--print("noVar array", v.tag)
		end
		--print(Tag.expArrayVar, TipoTag.naotipado, TipoBasico.naotipado, v.v, n, l)
		return makeNoV(Tag.expArrayVar, TipoTag.naotipado, TipoBasico.naotipado, v.v, n, l)
	else
		--print("here", Tag.expSimpVar, TipoTag.naotipado, TipoBasico.naotipado, v.v)
		return makeNoV(Tag.expSimpVar, TipoTag.naotipado, TipoBasico.naotipado, v.v)
	end
end

local function noNaoExp (op, exp)
	return { tag = Tag.expNao, tipo = makeTipo(TipoTag.simples, TipoBasico.bool), op = op,
					 exp = exp, linha = defs.linha, ehExp = true }
end

local function noMenosUnario (op, exp, exp2)
	--print("Menos ", op, op.s, exp, exp.v, exp2)
	return { tag = Tag.expOpNum, tipo = makeTipo(TipoTag.simples, TipoBasico.naotipado),
           ehExp = true, op = op, p1 = noInteiro(0), p2 = exp, linha = defs.linha }
end


local function noOpBoolExp (...) 
	local t = { ... }
	local p1 = t[1]
	local i = 2
	local n = #t
	
	assert(n % 2 == 1, "expOpBool n = " .. n)
	while i + 1 <= n do
		local op = t[i]
		local p2 = t[i + 1]
		p1 = makeNoOpBin(Tag.expOpBool, makeTipo(TipoTag.simples, TipoBasico.bool),
                     op, p1, p2)
		i = i + 2
	end

	return p1
end

local function noOpCompExp (...)
	local t = { ... }
	local p1 = t[1]
	local i = 2
	local n = #t

	assert(n % 2 == 1, "expOpComp n = " .. n)
	while i + 1 <= n do
		local op = t[i]
		local p2 = t[i + 1]
		p1 = makeNoOpBin(Tag.expOpComp, makeTipo(TipoTag.simples, TipoBasico.bool),
                     op, p1, p2)
		i = i + 2
	end

	return p1
end


local function noNovoArrayExp (tipoBase, ...)
	local t = {...}
	local n = #t
	local nexp = 0
	--print("noNovoArrayExp", n)
	for i, v in ipairs(t) do
		if v == "nil" then
			break	
		end
		--print(i, v)
		--print(i, v, v.ehExp, v.v)
		nexp = nexp + 1
	end
	return { tag = Tag.expNovoArray, tipo = makeTipo(TipoTag.array, tipoBase),
           v = t, dim = n, nexp = nexp, ehExp = true, linha = defs.linha }	
end


local function noOpNumExp (...)
	local t = { ... }

	local p1 = t[1]
	local i = 2
	local n = #t
	assert(n % 2 == 1, "expOpNum n = " .. n)
	while i + 1 <= n do
		local op = t[i]
		local p2 = t[i + 1]
		p1 = makeNoOpBin(Tag.expOpNum, makeTipo(TipoTag.simples, TipoBasico.naotipado),
                     op, p1, p2)
		i = i + 2
	end

	return p1
end


-- TODO: repensar o tipo de uma função: só simples? simples e array?
local function noChamadaFunc (f, ...)
	return { tag = Tag.expChamada, tipo = makeTipo(TipoTag.naoTipado, TipoBasico.naotipado),
           nome = f, args = { ... }, ehExp = true, linha = defs.linha } 
end

local function noCmdChamada (t)
	t.tag = Tag.cmdChamada
	--t.tipo = makeTipo(TipoTag.simples, TipoBasico.vazio)
	return t
end

local function noCmdAtrib (v, e)
	return makeNoCmd(Tag.cmdAtrib, v, e)
end

local function noCmdRepita (e, b)
	return { tag = Tag.cmdRepita, exp = e, bloco = b, linha = defs.linha }
end


local function noCmdSenaoSe (...)
	local t = { ... }
	if #t < 2 then
    assert(t[1] == "")
		return nil
	end
	local lista = {}
	local no = { tag = Tag.blocoSenaoSe }
	for i = 1, #t, 2 do
		local exp = t[i]
    local bloco = t[i + 1]
		lista[#lista + 1] = { tag = Tag.cmdSenaoSe, exp = exp, bloco = bloco, linha = defs.linha }		
	end
	no.lista = lista
	return no
end

local function noCmdSe (expSe, blocoSe, noSenaoSe, blocoSenao)
	local no = { tag = Tag.cmdSe, expSe = expSe, blocoSe = blocoSe,
               senaoSe = noSenaoSe, senao = blocoSenao, linha = defs.linha }
	return no
end

local function noBloco (...)
	local t = { ... }
	if #t == 1 and t[1] == "" then
		t = {}	
	end
	return { tag = Tag.bloco, tbloco = t, linha = defs.linha }
end

local function noDecVar (v, e)
	--print("DecVar ", v.tipo, v.tipo.tag, v.tipo.basico, v.linha, v.v)
	return { tag = Tag.decVar, --tipo = makeTipo(TipoTag.simples, TipoBasico.naotipado),
           v = v.v, exp = e, linha = v.linha }
end

--local function noDecArrayVar (v, e1, e2)
	--print("ArrayVar123", e1, e2, v.v, v.tipo, v.tipo.tag, v.tipo.basico)
--	return { tag = Tag.decArrayVar, --tipo = makeTipo(TipoTag.array, TipoBasico.naotipado),
  --         v = v.v, tam = e1, exp = e2, linha = v.linha }
--end

local function ehExpressao (e)
	return e.ehExp
end

local function ehComando (e)
	return e.tag == Tag.cmdSe or e.tag == Tag.cmdSenaoSe or
         e.tag == Tag.cmdRepita or e.tag == Tag.cmdAtrib or
         e.tag == Tag.cmdChamada          
end


local function noDecVarL (...)
	local t = { ... }
	local n = #t
	local tipo = t[1]
	--TODO: uma decVarLista não deveria ter tipo, apenas uma DecVar
	--print("noDecVarL", tipoBasico)
	local listaDecVar = { tag = Tag.decVarLista, linha = defs.linha }
	local tag = Tag.decVar
	if tipo.tag == TipoTag.array then
		tag = Tag.decArrayVar
	end
	local i = 2
	while i <= n do
		--print(t[i].tag)
		t[i].tag = tag
		t[i].tipo = t[1]
		i = i + 1		
	end
	local lista = table.pack(table.unpack(t, 2, n))
	listaDecVar.lista = lista
	return listaDecVar	
end


return {
	noInteiro = noInteiro,
  noReal = noReal,
  noTexto = noTexto,
  noBoolFalso = noBoolFalso,
  noBoolVerd = noBoolVerd,
  noId = noId,
	noTipo = noTipo,
	noVar = noVar,
	noNaoExp = noNaoExp,
	noMenosUnario = noMenosUnario,
	noOpNumExp = noOpNumExp,
	noOpCompExp = noOpCompExp,
	noOpBoolExp = noOpBoolExp,
	noNovoArrayExp = noNovoArrayExp,
	noCmdAtrib = noCmdAtrib,
	noCmdRepita = noCmdRepita,
	noCmdSe = noCmdSe,
	noCmdSenaoSe = noCmdSenaoSe,
  noChamadaFunc = noChamadaFunc,
  noCmdChamada = noCmdChamada,
	noDecVarL = noDecVarL,
	noDecVar = noDecVar,
	noDecArrayVar = noDecArrayVar,
	noBloco = noBloco,
	imprimeArvore = imprimeArvore,
	ehComando = ehComando,
	ehExpressao = ehExpressao,
	makeTipo = makeTipo
}
