
local cpu_bound = require("processos/cpu")
local io_bound = require("processos/io")


function love.load()
	player1 = cpu_bound.novo(0)
	player2 = io_bound.novo(0)
	atual = "cpu-bound"
	tempo = os.time()
	auxcpu = 0 -- auxiliar de cotagem de tempo cpu-bound
	auxio = 0 -- auxiliar de contagem de tempo io-bound

end

function love.update( dt )
	-- body
end

function love.draw(  )
	-- body
	escalonamento_rrobin()
	if(atual == "cpu-bound")then
		auxcpu = auxcpu+1/100 -- tempo que cada processo e executado
		love.graphics.print("\ncpu-bound executando".."\n".."PID: "..player1.pid.."\n")
		love.graphics.print("temp CPU: ".. auxcpu)

		
	else
		auxio = auxio+1/100
		love.graphics.print("\nio-bound executando\n".."PID: "..player2.pid.."\n")
		love.graphics.print("temp CPU: "..auxio)
	end
	
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

