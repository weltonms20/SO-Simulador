
local cpu_bound = require("processos/cpu")
local io_bound = require("processos/io")
--local fila = require("fila")
local fila={}
local cpu = {
	nome="juninho",
	tempo={cpu,io}
}


function love.load()
	processos={};
	processos[#processos+1] = cpu_bound.novo(2)--#processos eh o tamanho do vetor
	processos[#processos+1] = io_bound.novo(3)

	----------------------------------------------------------------------------------------
	adiciona_fila(processos[1])
	adiciona_fila(processos[2])

	if(#fila>0)then
		atual = primeiro_fila()
	else
		atual=0--significa nao fazer nada
	end
	if(#fila>1)then
		espera = espera_fila()
	else
		espera = 0--zero significa nao fazer nada
	end
	----------------------------------------------------------------------------------------
	tempo = os.time()
	numero_random= love.math.random(1,10)
	cpu.tempo.cpu = 0 -- auxiliar de cotagem de tempo cpu-bound
	cpu.tempo.io = 0 -- auxiliar de contagem de tempo io-bound

end

function love.update( dt )
	escalonamento_loteria()
	if(atual~=0 and processos[atual].tipo == "cpu-bound")then
		cpu.tempo.cpu = cpu.tempo.cpu+1/50 -- tempo que cada processo e executado
	else
		cpu.tempo.io = cpu.tempo.io+1/50
	end
	-- body
end

function love.draw(  )
	-- body
	if(atual~=0 and processos[atual].tipo == "cpu-bound")then
		love.graphics.print("\nNOME DA CPU = "..cpu.nome.."\ncpu-bound executando".."\n".."PID: "..processos[atual].pid.."\n")
		love.graphics.print("temp CPU: ".. cpu.tempo.cpu.."\n")
		
	elseif(atual~=0)then
		love.graphics.print("\nNOME DA CPU = "..cpu.nome.."\nio-bound executando\n".."PID: "..processos[atual].pid.."\n")
		love.graphics.print("temp CPU: "..cpu.tempo.io)
	end

	love.graphics.print("tamanho da fila "..#fila,250,0)
	for i=1,#fila do
		love.graphics.print("fila ["..i.."] "..fila[i].tipo.." pid = "..fila[i].pid,250,11*i)
	end

	
	
end

function sorteio()
	local aux = love.math.random(10)
	return aux
end

function escalonamento_rrobin() -- funcao escalonador round-robin
	if(atual~=0 and processos[atual].tipo == "io-bound") then
		if(os.time()-tempo>0.4) then -- tempo que o I/O fica executando na CPU
			tempo = os.time() -- quando o tempo termina a variavel tempo e atualizada 
			
			proximo_fila()
		end
	else
		if(os.time() - tempo>5) then -- tempo que o CPU-Bound fica executando na CPU
			tempo = os.time()

			proximo_fila()
		end
	end
end

function escalonamento_prioridades()
	if(atual~=0 and processos[atual].tipo == "io-bound")then
		if(atual~=0 and espera~=0 and processos[atual].prioridade > processos[espera].prioridade)then
			proximo_fila()
		else
			if(atual~=0 and espera~=0 and processos[atual].prioridade <= processos[espera].prioridade)then
				if(os.time()-tempo>0.4)then
					tempo =os.time()
					proximo_fila()
				end
			end
		end
	else
		if(os.time()-tempo>5)then
			tempo = os.time()
			proximo_fila()
		end
	end
end

function escalonamento_loteria()
-- body
	if (atual~=0 and processos[atual].token[numero_random]) then
		love.graphics.print("\n\n\nToken sorteado: "..numero_random)
		if(os.time()-tempo>5)then
			tempo = os.time()

			proximo_fila()

			aux = love.math.random(10)
		end

	elseif(espera~=0 and processos[espera].token[numero_random])then
			proximo_fila()
			love.graphics.print("\n\n\nToken sorteado: "..numero_random)
			if(os.time()-tempo>1)then
				tempo=os.time()

				proximo_fila()

				numero_random = love.math.random(10)
			end
	else
		numero_random = love.math.random(10)
	end
end


function escalonamento_multiplasfilas()
-- body
	

end

-------------------------SISTEMA DE FILA--------------------------

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
	adiciona_fila(temp)--coloca no final da fila
	remove_fila(1)--remove o primeiro da fila
	return fila[1] --retorna o proximo
end
function primeiro_fila()
	return 1
end
function espera_fila()
	return 2
end
