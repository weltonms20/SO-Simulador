--[[
Reposição - Projeto de um Simulador dos Algoritmos de Escalonamento
Descrição:
Os algoritmos de escalonamento são legais, né? O objetivo dessa tarefa é meter a mão na massa e implementar 
um simulador dos algoritmos de escalonamento!

É fortemente recomendado que o simulador tenha interface gráfica e ilustre o funcionamento de um escalonador 
de processos real. Você deve implementar os seguintes algoritmos estudados:

Escalonamento por chaveamento circular (Round-robin)
Escalonamento por prioridades
Múltiplas Filas
Escalonamento por loteria
Essa reposição pode ser feita em dupla.

Se o projeto puder ser acessado via web, melhor ainda. :)

Período:
Inicia em 20/12/2018 às 00h00 e finaliza em 24/12/2018 às 23h59
]]--


local anim8 = require 'anim8'
local cpu_bound = require("processos/cpu")
local io_bound = require("processos/io")
--local fila = require("fila") -- nao funcionou

local fila={} -- fila que guarda e processa todos os processos

local cpu = { -- tabela cpu (talvez precise ai ja deixei pronta)
	nome="juninho",
	tempo={cpu,io}
}
local prioridade=0


function love.load()
	processos={}--essa tabela agora só guarda todos os processos ja criados, todo processamento eh feito na fila
	--processos[#processos+1] = cpu_bound.novo(2)--#processos eh o tamanho do vetor
	--processos[#processos+1] = io_bound.novo(3)

	----------------------------------------------------------------------------------------
	--adiciona_fila(processos[1])
	--adiciona_fila(processos[2])

	if(#fila>0)then
		atual = primeiro_fila()
	else
		atual=0--significa nao fazer nada
	end
	if(#fila>1)then
		espera = espera_fila() -- segundo da fila de espera 
	else
		espera = 0--zero significa nao fazer nada
	end
	----------------------------------------------------------------------------------------
	tempo = os.time()
	numero_random= love.math.random(1,10)
	cpu.tempo.cpu = 0 -- auxiliar de cotagem de tempo cpu-bound
	cpu.tempo.io = 0 -- auxiliar de contagem de tempo io-bound

	-------------------------------graficos--------------------------------------------------

	buttom = love.graphics.newImage("imagens/button.png")
	grid_buttom = anim8.newGrid(502, 248, buttom:getWidth(), buttom:getHeight())
	anim = anim8.newAnimation(grid_buttom('1-2',1), 0.1,"pauseAtStart")


end

function love.update( dt )
	escalonamento_loteria()
	if(atual~=0 and fila[atual].tipo == "cpu_bound")then
		cpu.tempo.cpu = cpu.tempo.cpu+dt -- tempo que cada processo e executado
	else
		cpu.tempo.io = cpu.tempo.io+dt
	end
	-- body
end

function love.draw( dt )
	-- body
	--button(100,100,0.3,0.3,"texto")
	if(atual~=0 and fila[atual].tipo == "cpu_bound")then
		love.graphics.print("\nNOME DA CPU = "..cpu.nome.."\ncpu-bound executando\n".."PID: "..fila[atual].pid.."\ntime = "..fila[atual].time.."\n status = "..fila[atual].status.."\n prioridade = "..fila[atual].prioridade.."\n")
		love.graphics.print("temp CPU: ".. cpu.tempo.cpu.."\n")
		
	elseif(atual~=0)then
		love.graphics.print("\nNOME DA CPU = "..cpu.nome.."\nio-bound executando\n".."PID: "..fila[atual].pid.."\ntime = "..fila[atual].time.."\n status = "..fila[atual].status.."\n prioridade = "..fila[atual].prioridade.."\n")
		love.graphics.print("temp CPU: "..cpu.tempo.io)
	end
	love.graphics.print("Pressione 'c' para adicionar um novo processo de CPU_Bound com prioridade "..prioridade,0,500)
	love.graphics.print("Pressione 'i' para adicionar um novo processo de IO_Bound com prioridade "..prioridade,0,520)
	love.graphics.print("Pressione '+' para aumentar a prioridade ",0,540)
	love.graphics.print("Pressione '-' para dominuir a prioridade ",0,560)
	love.graphics.print("atual =  "..atual.." proximo = "..espera,0,580)

	love.graphics.print("tamanho da fila "..#fila,250,0)
	for i=1,#fila do
		love.graphics.print("fila ["..i.."] "..fila[i].tipo.." pid = "..fila[i].pid,250,11*i)
	end

end

function love.keypressed(key)
	if key == "c" then
		processos[#processos+1] = cpu_bound.novo(prioridade)--#processos eh o tamanho do vetor
		adiciona_fila(processos[#processos])
		atual = primeiro_fila()
		if(#fila>1)then
			espera = espera_fila()
		end
	elseif key == "i" then
		processos[#processos+1] = io_bound.novo(prioridade)
		adiciona_fila(processos[#processos])
		atual = primeiro_fila()
		if(#fila>1)then
			espera = espera_fila()
		end
	elseif (key == "+" or key == "kp+") then
		prioridade=prioridade+1
	elseif (key == "-" or key == "kp-") then
		prioridade=prioridade-1
	end
end


-------------------------------------------------------------------------------------------------------------------
function sorteio()
	local aux = love.math.random(10)
	return aux
end

function escalonamento_rrobin() -- funcao escalonador round-robin
	if(atual~=0 and fila[atual].tipo == "io_bound") then
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
	if(atual~=0 and fila[atual].tipo == "io_bound")then
		if(atual~=0 and espera~=0 and fila[atual].prioridade > fila[espera].prioridade)then
			proximo_fila()
		else
			if(atual~=0 and espera~=0 and fila[atual].prioridade <= fila[espera].prioridade)then
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
	if (atual~=0 and fila[atual].token[numero_random]) then
		love.graphics.print("\n\n\nToken sorteado: "..numero_random)
		if(os.time()-tempo>5)then
			tempo = os.time()

			proximo_fila()

			aux = love.math.random(10)
		end

	elseif(espera~=0 and fila[espera].token[numero_random])then
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


-- ------------------------FUNCOES GRAFICAS-----------------------------
--[[
function colisao(obj1X, obj1Y, obj1W, obj1H, obj2X, obj2Y)
	if (obj2X>obj1X ) then
		--if(obj2Y>obj1Y and obj2Y < (obj1Y+obj1H)) then
			return 1
		--end
	else
		return 0
	end
end

function button(x,y,w,h,texto,event,param1,param2)
	--desenha botao
	love.graphics.print("\n x = "..love.mouse.getX().."\n",300,400)
	love.graphics.print("\n yfilae.mouse.getY().."\n",300,420)
	love.graphics.print("\n x = "..x.."\n",300,440)
	love.graphics.print(" y = "..y.."\n",300,480)
	anim:draw(buttom, x, y,0,w,h)
	local mx, my = love.mouse.getPosition( )
	if(colisao(x,y,250,72,mx,my))then
		love.graphics.print("\n colisao\n",300,500)
		--anim:update(dt)	
		if(not event)then
			return
		end
		if((not param1) and (not param2))then
			event()
		elseif((not param2))then
			event(param1)
		elseif((not param1))then
			event(param2)
		elseif(param1 and param2)then
			event(param1,param2)
		end
	end

end
function new_button(x,y,w,h,texto,evento,param1,param2)
	-- body
end
]]--