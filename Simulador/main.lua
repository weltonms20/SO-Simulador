
local cpu_bound = require("processos/cpu")
local io_bound = require("processos/io")


function love.load()
	player1 = cpu_bound.novo(2)
	player2 = io_bound.novo(3)
	atual = "cpu-bound"
	tempo = os.time()
	aux = love.math.random(1,10)
	auxcpu = 0 -- auxiliar de cotagem de tempo cpu-bound
	auxio = 0 -- auxiliar de contagem de tempo io-bound

end

function love.update( dt )
	-- body
end

function love.draw(  )
	-- body
	escalonamento_loteria()
	if(atual == "cpu-bound")then
		auxcpu = auxcpu+1/50 -- tempo que cada processo e executado
		love.graphics.print("\ncpu-bound executando".."\n".."PID: "..player1.pid.."\n")
		love.graphics.print("temp CPU: ".. auxcpu.."\n")
		
	else
		auxio = auxio+1/50
		love.graphics.print("\nio-bound executando\n".."PID: "..player2.pid.."\n")
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
	if(atual == "io-bound")then
		if(player1.prioridade > player2.prioridade)then
			atual = "cpu-bound"
		else
			if(player1.prioridade <= player2.prioridade)then
				if(os.time()-tempo>0.4)then
					tempo =os.time()
					atual = "cpu-bound"
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




