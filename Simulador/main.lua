
local cpu_bound = require("processos/cpu")
local io_bound = require("processos/io")


function love.load()
	processos={};
	processos[#processos+1] = cpu_bound.novo(2)--#processos eh o tamanho do vetor
	processos[#processos+1] = io_bound.novo(3)

	----------------------------------------------------------------------------------------

	fila={}
	fila[#fila+1] = processos[1]
	fila[#fila+1] = processos[2]

	if(#fila>0)then
		atual = fila[1]
	else
		atual=0--significa nao fazer nada
	end
	if(#fila>1)then
		proximo = fila[2]
	else
		proximo = 0--zero significa nao fazer nada
	end
	----------------------------------------------------------------------------------------
	tempo = os.time()
	numero_random= love.math.random(1,10)
	auxcpu = 0 -- auxiliar de cotagem de tempo cpu-bound
	auxio = 0 -- auxiliar de contagem de tempo io-bound

end

function love.update( dt )
	escalonamento_loteria()
	if(atual~=0 and processos[atual].tipo == "cpu-bound")then
		auxcpu = auxcpu+1/50 -- tempo que cada processo e executado
	else
		auxio = auxio+1/50
	end
	-- body
end

function love.draw(  )
	-- body
	if(atual~=0 and processos[atual].tipo == "cpu-bound")then
		love.graphics.print("\ncpu-bound executando".."\n".."PID: "..processos[atual].pid.."\n")
		love.graphics.print("temp CPU: ".. auxcpu.."\n")
		
	else
		love.graphics.print("\nio-bound executando\n".."PID: "..processos[atual].pid.."\n")
		love.graphics.print("temp CPU: "..auxio)
	end
	
end

function sorteio()
	aux = love.math.random(10)
	return aux
end

function escalonamento_rrobin() -- funcao escalonador round-robin
	if(processos[atual].tipo == "io-bound") then
		if(os.time()-tempo>0.4) then -- tempo que o I/O fica executando na CPU
			tempo = os.time() -- quando o tempo termina a variavel tempo e atualizada 
			
			temp = atual
			atual = espera -- variavel atual muda
			espera = temp 
		end
	else
		if(os.time() - tempo>5) then -- tempo que o CPU-Bound fica executando na CPU
			tempo = os.time()

			temp = atual
			atual = espera -- variavel atual muda
			espera = temp 
		end
	end
end

function escalonamento_prioridades()
	if(processos[atual].tipo == "io-bound")then
		if(processos[atual].prioridade > processos[espera].prioridade)then
			temp = atual --variavel temporaria
			atual = espera	-- isso tem que ser mudado pois nao posso passar o indice aqui
							-- esse indice tem que vir de algum lugar (alguma funcao tem que dizer qual esse indice)
			espera = temp -- tem que ser mudado teambem , ttemos que ter uma fila
		else
			if(processos[atual].prioridade <= processos[espera].prioridade)then
				if(os.time()-tempo>0.4)then
					tempo =os.time()
					temp = atual
					atual = espera
					espera = temp
				end
			end
		end
	else
		if(os.time()-tempo>5)then
			tempo = os.time()
			atual = "io-bound"
		end
	end
end

function escalonamento_loteria()
-- body
	atual = 1
	if (processos[atual].token[aux]) then
		atual = 1
		love.graphics.print("\n\n\nToken sorteado: "..aux)
		if(os.time()-tempo>5)then
			tempo = os.time()

			temp = atual
			atual = espera
			espera = temp

			aux = love.math.random(10)
		end

	elseif(processos[espera].token[aux])then
			temp = atual
			atual = espera
			espera = temp
			love.graphics.print("\n\n\nToken sorteado: "..aux)
			if(os.time()-tempo>1)then
				tempo=os.time()

				temp = atual
				atual = espera
				espera = temp

				aux = love.math.random(10)
			end
	else
		aux = love.math.random(10)
	end
end


function escalonamento_multiplasfilas()
-- body
	

end


-------------------------SISTEMA DE FILA--------------------------
function troca_fila(nodeA, nodeB)
	self.fila[nodeA],self.fila[nodeB] = self.fila[nodeB],self.fila[nodeA]
end
function adiciona_fila(node)
	self.fila[#fila+1] = node
end
function remove_fila(indice)
	self.fila.remove(indice)
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


