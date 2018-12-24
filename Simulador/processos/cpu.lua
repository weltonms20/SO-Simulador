local cpu_bound = {}

function cpu_bound.novo(prioridade)
	return {
		tipo = "cpu_bound",
		pid = math.random(100000,999999),
		time = 5,
		status = 0,--quando botar uma variavel status bota tipo uma legenda como eu botei lá em baixo
		prioridade = prioridade or 1,-- prioridade assume o que foi passado ou se nao foi passado assume 1
		token = {1,2,3}
	}

end

return cpu_bound

-- status 0 = 
-- status 1 = 
-- status 2 = 
-- ...

--toke 1 =
--toke 2 =
--toke 3 = 
