local cpu_bound = {}

function cpu_bound.novo(prioridade)
	return {
		pid = math.random(100000,999999),
		time = 5,
		status = 0,
		prioridade = prioridade,
		token = {1,2,3}
	}

end

return cpu_bound
