local io_bound = {}

function io_bound.novo(prioridade)
	return{
		pid = math.random(100000,999999),
		time = 1,
		status = 1,
		prioridade = prioridade,
		token = {4,5,6,7}
	}
end

return io_bound