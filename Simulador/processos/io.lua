local io_bound = {}

function io_bound.novo(prioridade)
	return{
		tipo = "io_bound",
		pid = math.random(100000,999999),
		time = 1,
		status = 1,
		prioridade = prioridade or 1,
		token = {4,5,6,7}
	}
end

return io_bound


-- status 0 = 
-- status 1 = 
-- status 2 = 

--toke 4 =
--toke 5 =
--toke 6 = 
--toke 7 = 