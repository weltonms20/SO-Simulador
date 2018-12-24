
local cpu_bound = require("processos/cpu")
local io_bound = require("processos/io")


function love.load()
	processos={};
	atual = 0--processo atual para ser rodado
	proximo = 1 -- processo em espera (tem que se criada uma fila)
	tempo = os.time()
	aux = love.math.random(1,10)
	auxcpu = 0 -- auxiliar de cotagem de tempo cpu-bound
	auxio = 0 -- auxiliar de contagem de tempo io-bound

end

function love.update( dt )
	processos[1] = cpu_bound.novo(2)
	processos[2] = io_bound.novo(3)
	escalonamento_loteria()
	if(processos[atual].tipo == "cpu-bound")then
		auxcpu = auxcpu+1/50 -- tempo que cada processo e executado
		
	else
		auxio = auxio+1/50
	end
	-- body
end

function love.draw(  )
	-- body
	if(processos[atual].tipo == "cpu-bound")then
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
	if(atual == "io-bound") then
		if(os.time()-tempo>0.4) then -- tempo que o I/O fica executando na CPU
			tempo = os.time() -- quando o tempo termina a variavel tempo e atualizada 
			atual = "cpu-bound" -- variavel atual muda
		end
	else
		if(os.time() - tempo>5) then -- tempo que o CPU-Bound fica executando na CPU
			tempo = os.time()
			atual = "io-bound"
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
	atual = "nada"
	if (player1.token[aux]) then
		atual = "cpu-bound"
		love.graphics.print("\n\n\nToken sorteado: "..aux)
		if(os.time()-tempo>5)then
			tempo = os.time()
			atual = "io-bound"
			aux = love.math.random(10)
		end

	elseif(player2.token[aux])then
			atual = "io-bound"
			love.graphics.print("\n\n\nToken sorteado: "..aux)
			if(os.time()-tempo>1)then
				tempo=os.time()
				atual = "cpu-bound"
				aux = love.math.random(10)
			end
	else
		aux = love.math.random(10)
	end
end


function escalonamento_multiplasfilas()
-- body
	

end




