
local cpu_bound = require("processos/cpu")
local io_bound = require("processos/io")


function love.load()
	processos={};
	processos[#processos+1] = cpu_bound.novo(2)--#processos eh o tamanho do vetor
	processos[#processos+1] = io_bound.novo(3)

	----------------------------------------------------------------------------------------

	fila={}
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
	tempo_cpu = 0 -- auxiliar de cotagem de tempo cpu-bound
	tempo_io = 0 -- auxiliar de contagem de tempo io-bound

end

function love.update( dt )
	escalonamento_loteria()
	if(atual~=0 and processos[atual].tipo == "cpu-bound")then
		tempo_cpu = tempo_cpu+1/50 -- tempo que cada processo e executado
	else
		tempo_io = tempo_io+1/50
	end
	-- body
end

function love.draw(  )
	-- body
	if(atual~=0 and processos[atual].tipo == "cpu-bound")then
		love.graphics.print("\ncpu-bound executando".."\n".."PID: "..processos[atual].pid.."\n")
		love.graphics.print("temp CPU: ".. tempo_cpu.."\n")
		
	else
		love.graphics.print("\nio-bound executando\n".."PID: "..processos[atual].pid.."\n")
		love.graphics.print("temp CPU: "..tempo_io)
	end
	
end

function sorteio()
	local aux = love.math.random(10)
	return aux
end

function escalonamento_rrobin() -- funcao escalonador round-robin
	if(processos[atual].tipo == "io-bound") then
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
	if(processos[atual].tipo == "io-bound")then
		if(processos[atual].prioridade > processos[espera].prioridade)then
			proximo_fila()
		else
			if(processos[atual].prioridade <= processos[espera].prioridade)then
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
	if (processos[atual].token[numero_random]) then
		love.graphics.print("\n\n\nToken sorteado: "..numero_random)
		if(os.time()-tempo>5)then
			tempo = os.time()

			proximo_fila()

			aux = love.math.random(10)
		end

	elseif(processos[espera].token[numero_random])then
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
	fila.remove(indice)
end
function imprime_fila()
	for i=1,#fila do
		print("--------------------------------------------------------")
		print(fila[i].tipo)
		print(fila[i].pid)
		print(fila[i].time)
		print(fila[i].status)
		print(fila[i].prioridade)
		print("--------------------------------------------------------")
	end
end
function imprimeNode_fila(indice)
	if(indice<=#fila)then
		print("--------------------------------------------------------")
		print(fila[indice].tipo)
		print(fila[indice].pid)
		print(fila[indice].time)
		print(fila[indice].status)
		print(fila[indice].prioridade)
		print("--------------------------------------------------------")
	else 
		print("imprimindo indice null")
	end
end
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

