
function love.load( ... )
	-- body
	auxcpu = 0
	auxio = 0
	atual = "cpu-bound"
	tempo = os.time()
	apoio = "\ncpu-bound executando\n"
end

function love.update( dt )
	-- body
end

function love.draw()
	-- body
	escalonamento_rrobin()
	if(atual == "cpu-bound")then
		auxcpu = auxcpu+1/100
		love.graphics.print(apoio)
		love.graphics.print ("temp CPU: "..auxcpu)
		
	else
		auxio = auxio+1/100
		love.graphics.print("\nio-bound executando\n")
		love.graphics.print("tem CPU: "..auxio)
	end
end

function escalonamento_rrobin()
	if(atual == "io-bound") then
		if(os.time()-tempo>0.4) then
			tempo = os.time()
			atual = "cpu-bound"
		end
	else
		if(os.time() - tempo>5) then
			tempo = os.time()
			atual = "io-bound"
		end
	end
end



