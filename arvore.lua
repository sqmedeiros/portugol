local defs = require 'defs'

local Tipo = defs.Tipo
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
	if t.v ~= nil then
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
  elseif t.tag == Tag.decVar then
    print(t.tag, t.tipo, msgLinha(t.linha))
		imprimeArvore(t.var, tab + n)
    if (t.exp) then
    	imprimeArvore(t.exp, tab + n)
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

local function makeNoV (tag, tipo, v)
  assert(tag ~= nil and tipo ~= nil, tag, tipo)
	--print("makeNoV", v, defs.linha)
	return { tag = tag, tipo = tipo, v = v, linha = defs.linha, ehExp = true }
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
	return makeNoV(Tag.expInt, Tipo.inteiro, tonumber(v)) 
end

local function noReal (v)
	return makeNoV(Tag.expNum, Tipo.numero, tonumber(v))
end

local function noTexto (v)
	return makeNoV(Tag.expTexto, Tipo.texto, v)
end

local function noBoolFalso ()
	return makeNoV(Tag.expBool, Tipo.bool, false) 
end

local function noBoolVerd ()
	return makeNoV(Tag.expBool, Tipo.bool, true) 
end

local function noId (v)
	return makeNoV(Tag.expVar, Tipo.naotipado, v)
end

local function noNaoExp (op, exp)
	return { tag = Tag.expNao, tipo = Tipo.naotipado, op = op,
					 exp = exp, linha = defs.linha, ehExp = true }
end

local function noMenosUnario (op, exp, exp2)
	--print("Menos ", op, op.s, exp, exp.v, exp2)
	return { tag = Tag.opNumExp, tipo = Tipo.naotipado, ehExp = true,
					 op = op, p1 = noInteiro(0), p2 = exp, linha = defs.linha }
end


local function noOpBoolExp (...) 
	local t = { ... }
	local p1 = t[1]
	local i = 2
	local n = #t
	
	assert(n % 2 == 1, "opBoolExp n = " .. n)
	while i + 1 <= n do
		local op = t[i]
		local p2 = t[i + 1]
		p1 = makeNoOpBin(Tag.opBoolExp, Tipo.naotipado, op, p1, p2)
		i = i + 2
	end

	return p1
end

local function noOpCompExp (...)
	local t = { ... }
	local p1 = t[1]
	local i = 2
	local n = #t

	assert(n % 2 == 1, "opCompExp n = " .. n)
	while i + 1 <= n do
		local op = t[i]
		local p2 = t[i + 1]
		p1 = makeNoOpBin(Tag.opCompExp, Tipo.naotipado, op, p1, p2)
		i = i + 2
	end

	return p1
end

local function noOpNumExp (...)
	local t = { ... }

	local p1 = t[1]
	local i = 2
	local n = #t
	assert(n % 2 == 1, "opNumExp n = " .. n)
	while i + 1 <= n do
		local op = t[i]
		local p2 = t[i + 1]
		p1 = makeNoOpBin(Tag.opNumExp, Tipo.naotipado, op, p1, p2)
		i = i + 2
	end

	return p1
end

local function noChamadaFunc (f, ...)
	return { tag = Tag.expChamda, tipo = Tipo.naotipado, nome = f,
           args = { ... }, ehExp = true, linha = defs.linha } 
end

local function noCmdChamada (t)
	t.tag = Tag.cmdChamada
	t.tipo = Tipo.vazio
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
	return { tag = Tag.decVar, tipo = Tipo.naotipado, var = v, exp = e, linha = defs.linha }
end

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
	local listaDecVar = { tag = Tag.decVarLista, tipo = tipo, linha = defs.linha }
	local i = 2
	while i <= n do
		t[i].tipo = tipo
    t[i].var.tipo = tipo
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
	noNaoExp = noNaoExp,
	noMenosUnario = noMenosUnario,
	noOpNumExp = noOpNumExp,
	noOpCompExp = noOpCompExp,
	noOpBoolExp = noOpBoolExp,
	noCmdAtrib = noCmdAtrib,
	noCmdRepita = noCmdRepita,
	noCmdSe = noCmdSe,
	noCmdSenaoSe = noCmdSenaoSe,
  noChamadaFunc = noChamadaFunc,
  noCmdChamada = noCmdChamada,
	noDecVarL = noDecVarL,
	noDecVar = noDecVar,
	noBloco = noBloco,
	imprimeArvore = imprimeArvore,
	ehComando = ehComando,
	ehExpressao = ehExpressao
}
