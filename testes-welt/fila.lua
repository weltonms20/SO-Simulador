
-------------------------SISTEMA DE FILA PROCESSOS E SUSPENSOES--------------------------

function troca_fila(nodeA, nodeB)
	fila[nodeA],fila[nodeB] = fila[nodeB],fila[nodeA]
end
function adiciona_fila(node)
	fila[#fila+1] = node
end
function remove_fila(indice)
	table.remove(fila, indice)
end
--[[
function imprime_fila()
	for i=1,#fila do
		love.graphics.print("--------------------------------------------------------\n")
		love.graphics.print("-------------fila prioridade node ["..i.. "]----------------------\n")
		love.graphics.print("tipo = " .. fila[i].tipo .. "\n")
		love.graphics.print("pid = " .. fila[i].pid .. "\n")
		love.graphics.print("time = " .. fila[i].time .. "\n")
		love.graphics.print("status = " .. fila[i].status .. "\n")
		love.graphics.print("prioridade = " .. fila[i].prioridade .. "\n")
		love.graphics.print("--------------------------------------------------------\n")
	end
end
function imprimeNode_fila(indice)
	if(indice<=#fila)then
		love.graphics.print("--------------------------------------------------------\n")
		love.graphics.print("-------------fila prioridade node ["..indice.. "]--------------------------\n")
		love.graphics.print("tipo = " .. fila[indice].tipo .. "\n")
		love.graphics.print("pid = " .. fila[indice].pid .. "\n")
		love.graphics.print("time = " .. fila[indice].time .. "\n")
		love.graphics.print("status = " .. fila[indice].status .. "\n")
		love.graphics.print("prioridade = " .. fila[indice].prioridade .. "\n")
		love.graphics.print("--------------------------------------------------------\n")
	else 
		love.graphics.print("imprimindo indice null")
	end
end
]]--
function proximo_fila()
	local temp = fila[1]
	if(temp.status=="encerrar")then --remove
		remove_processo(temp.pid)
	elseif(temp.status=="suspender")then -- suspende
		suspensos[#suspensos+1] = temp
	elseif(temp.status=="processando")then
		adiciona_fila(temp)--coloca no final da fila
		fila[#fila].status = "espera"
	end
	remove_fila(1)--remove o primeiro da fila
	if(fila[1].status=="encerrar")then -- remove esse processo
		proximo_fila() -- pula esse processo
	elseif(fila[1].status=="suspender")then -- suspende tal processo
		proximo_fila() -- pula esse processo
	elseif(fila[1].status=="espera")then
		fila[1].status = "processando"
	end
	return fila[1] --retorna o proximo
end
function primeiro_fila()
	return 1
end
function espera_fila()
	return 2
end

function remove_suspenso(id)
	for i=1,#suspensos do
		if(suspensos[i].pid==id)then
			table.remove(suspensos,i)
			return
		end
	end
end
function remove_processo(id)
	for i=1,#processos do
		if(processos[i].pid==id)then
			table.remove(processos,i)
			return
		end
	end
end
