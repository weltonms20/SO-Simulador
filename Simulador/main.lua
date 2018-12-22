function love.load()
	whale = love.graphics.newImage("imagens/teste.png")
end
function love.draw()
	love.graphics.draw(whale, 0, 0,0,0.5,0.5)
end