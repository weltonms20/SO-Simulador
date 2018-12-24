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

require "fila"
require "escalonamentos"
anim8 = require 'anim8'
cpu_bound = require("processos/cpu")
io_bound = require("processos/io")
--local fila = require("fila") -- nao funcionou

fila={} -- fila que guarda e processa todos os processos
suspensos = {}

cpu = { -- tabela cpu (talvez precise ai ja deixei pronta)
	nome="juninho",
	status="esperando",
	tipo_escalonamento=nil,
	tempo={cpu,io},
	valid="NULL"
}
prioridade=0


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
	cursor = {y=6,base_y=11,pos=1}
	buttom = love.graphics.newImage("imagens/button.png")
	grid_buttom = anim8.newGrid(502, 248, buttom:getWidth(), buttom:getHeight())
	anim = anim8.newAnimation(grid_buttom('1-2',1), 0.1,"pauseAtStart")

	imageplay=love.graphics.newImage("imagens/play.png")
	imageplay_w=imageplay:getWidth()
	imageplay_h=imageplay:getHeight()

	teste=0
   printx = 0
   printy = 0


end

function love.update( dt )
	if(cpu.status=="executando")then
		if(cpu.tipo=="Loteria")then
			escalonamento_loteria()
		elseif(cpu.tipo=="Prioridades")then
			escalonamento_prioridades()
		elseif(cpu.tipo=="Round-robin")then
			escalonamento_rrobin()
		elseif(cpu.tipo=="Filas")then
			escalonamento_multiplasfilas()
		end

		if(atual~=0 and fila[atual].tipo == "cpu_bound")then
			cpu.tempo.cpu = cpu.tempo.cpu+dt -- tempo que cada processo e executado
		else
			cpu.tempo.io = cpu.tempo.io+dt
		end
		-- body
		if(cursor.pos>#processos)then
			cursor.pos=#processos
		end
		cursor.y= (cursor.base_y*cursor.pos)+cursor.base_y
	elseif(cpu.status=="esperando")then --menu inicial

	end
end

function love.draw( dt )
	-- body
	if(cpu.status=="executando")then
		menu_processamento()
	elseif(cpu.status=="esperando")then
		menu_start()
	end
	--button(100,100,0.3,0.3,"texto")
	if(atual~=0 and fila[atual].tipo == "cpu_bound")then
		love.graphics.print("\nNOME DA CPU = "..cpu.nome.."\ncpu-bound executando\n".."PID: "..fila[atual].pid.."\ntime = "..fila[atual].time.."\n status = "..fila[atual].status.."\n prioridade = "..fila[atual].prioridade.."\n")
		love.graphics.print("temp CPU: ".. cpu.tempo.cpu.."\n")
		
	elseif(atual~=0)then
		love.graphics.print("\nNOME DA CPU = "..cpu.nome.."\nio-bound executando\n".."PID: "..fila[atual].pid.."\ntime = "..fila[atual].time.."\n status = "..fila[atual].status.."\n prioridade = "..fila[atual].prioridade.."\n")
		love.graphics.print("temp CPU: "..cpu.tempo.io)
	end

	love.graphics.print("Pressione Esq para terminar a simulação " .. teste,0,780)

--------------------------------------------------filas e processos -------------------------------------
	love.graphics.print("tamanho da fila "..#fila,300,0)
	for i=1,#fila do
		love.graphics.print("fila ["..i.."] "..fila[i].tipo.." pid = "..fila[i].pid.." prioridade = "..fila[i].prioridade,300,11*i)
	end
	love.graphics.print("tamanho da tabela de processos suspensos "..#suspensos,600,0)
	for i=1,#suspensos do
		love.graphics.print("suspensos ["..i.."] "..suspensos[i].tipo.." pid = "..suspensos[i].pid.." prioridade = "..suspensos[i].prioridade,600,11*i)
	end

	love.graphics.print("tamanho da tabela de processos "..#fila,950,0)
	for i=1,#processos do
		if(cursor.pos==i)then
			love.graphics.setColor( 250,0,0)
		else
			love.graphics.setColor( 250,250,250)
		end
		love.graphics.print("["..i.."] "..processos[i].tipo.." pid = "..processos[i].pid.." status = "..processos[i].status,950,11*i)
	end
	love.graphics.setColor( 250,250,250)
------------------------------------------------cursor ----------------------------------------------------
	
    love.graphics.circle("fill", 940, cursor.y, 6, 10)
    if(#processos==50)then
		love.graphics.setColor( 250,0,0)
		love.graphics.print("ATENCAO LIMITE DE PROCESSOS ALCANCADO",650,600)
		love.graphics.setColor( 250,250,250)
    elseif(#processos>40)then
		love.graphics.setColor( 250,250,0)
		love.graphics.print("CUIDADO LIMITE DE PROCESSOS EH 50",650,600)
		love.graphics.setColor( 250,250,250)
    end
    if(cpu.valid=="valido")then
		love.graphics.setColor( 0,250,0)
		love.graphics.print("COMANDO VALIDO",650,640)
		love.graphics.setColor( 250,250,250)
    elseif(cpu.valid=="nao_valido")then
		love.graphics.setColor( 250,0,0)
		love.graphics.print("COMANDO INVALIDO",650,640)
		love.graphics.setColor( 250,250,250)
    end
--testes--------------------------------------

	love.graphics.setColor(255,51,51)
	love.graphics.draw(imageplay, 500, 700)
	love.graphics.setColor(255,255,255)
   love.graphics.print("Text"..printx..","..printy, printx, printy)

end


function love.mousepressed(x, y, button)
	if (x >= 500) and (x<=614) and (y>=700) and (y<=760) and button == 1 then
		teste=1
	end
end
--[[
function love.mousepressed(x, y, button, istouch)
   if button == 1 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
      printx = x
      printy = y
   end
end
]]

function love.keypressed(key)
	if(cpu.status=="executando")then
		if key == "c" then
			if(#processos<50)then
				cpu.valid = "valido"
				processos[#processos+1] = cpu_bound.novo(prioridade)--#processos eh o tamanho do vetor
				adiciona_fila(processos[#processos])
				if(#fila<2)then
					atual = primeiro_fila()
					fila[atual].status = "processando"
					if(#fila>1)then
						espera = espera_fila()
					end
				end
			else
				cpu.valid = "nao_valido"
			end
		elseif key == "i" then
			if(#processos<50)then
				cpu.valid = "valido"
				processos[#processos+1] = io_bound.novo(prioridade)
				adiciona_fila(processos[#processos])
				atual = primeiro_fila()
				if(#fila<2)then
					atual = primeiro_fila()
					fila[atual].status = "processando"
					if(#fila>1)then
						espera = espera_fila()
					end
				end
			else
				cpu.valid = "nao_valido"
			end
		elseif (key == "+" or key == "kp+") then
			prioridade=prioridade+1
		elseif (key == "-" or key == "kp-") then
			prioridade=prioridade-1
		elseif (key == "up") then
			if(cursor.pos>1)then
				cursor.pos = cursor.pos-1
			end
		elseif (key == "down") then
			if(cursor.pos<#processos)then
				cursor.pos = cursor.pos+1
			end
		elseif (key == "q") then--encerrar o processo
			if(cursor.pos>0)then
				if(processos[cursor.pos].status ~= "processando")then--para nao matar um processo em execussao
					processos[cursor.pos].status = "encerrar"
					cpu.valid = "valido"
				else
					cpu.valid = "nao_valido"
				end
			end		
		elseif (key == "x") then--suspender o processo
			if(cursor.pos>0)then
				if(processos[cursor.pos].status ~= "processando")then--para nao matar um processo em execussao
					processos[cursor.pos].status = "suspender"
					cpu.valid = "valido"
				else
					cpu.valid = "nao_valido"
				end
			end			
		elseif (key == "s") then--suspender o processo
			if(cursor.pos>0 and processos[cursor.pos].status=="suspender")then
					cpu.valid = "valido"
				processos[cursor.pos].status = "espera"
				remove_suspenso(processos[cursor.pos].pid)
				adiciona_fila(processos[cursor.pos])
			else
				cpu.valid = "nao_valido"
			end		
		end
	elseif(cpu.status=="esperando")then
		if (key == "l") then
			cpu.tipo="Loteria"
			cpu.status="executando"
		elseif (key == "r")then
			cpu.tipo="Round-robin"
			cpu.status="executando"
		elseif (key == "p") then
			cpu.tipo="Prioridades"
			cpu.status="executando"
		elseif (key == "f") then
			cpu.tipo="Filas"
			cpu.status="executando"
		end
	end
	if (key == "escape") then--encerra independente de estado
		love.event.quit()
	end
end


-------------------------------------------------------------------------------------------------------------------
function sorteio()
	local aux = love.math.random(10)
	return aux
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

function menu_processamento()
	love.graphics.print("Pressione 'c' para adicionar um novo processo de CPU_Bound com prioridade "..prioridade,0,600)
	love.graphics.print("Pressione 'i' para adicionar um novo processo de IO_Bound com prioridade "..prioridade,0,620)
	love.graphics.print("Pressione '+' para aumentar a prioridade ",0,640)
	love.graphics.print("Pressione '-' para dominuir a prioridade ",0,660)
	love.graphics.print("Pressione 'x' para suspendere () o processo  ",0,680)
	love.graphics.print("Pressione 'q' para encerrar (quit) o processo  ",0,700)
	love.graphics.print("Pressione 's' para retomar um processo suspenso ",0,720)
	love.graphics.print("atual =  "..atual.." proximo = "..espera,0,740)

	love.graphics.print("cursor.pos =  "..cursor.pos,0,760)
end
function menu_start()
	love.graphics.print("Pressione 'r' para Escalonamento [Round-robin]",0,600)
	love.graphics.print("Pressione 'p' para Escalonamento por [Prioridades] ",0,620)
	love.graphics.print("Pressione 'f' para Escalonamento por [Múltiplas Filas] ",0,640)
	love.graphics.print("Pressione 'l' para Escalonamento por [Loteria] ",0,660)

end