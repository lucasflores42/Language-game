# -------------------------------------------------------------------------------
#								Packages
# -------------------------------------------------------------------------------

using OffsetArrays, StructArrays, Printf, DelimitedFiles, Statistics, Random


# -------------------------------------------------------------------------------
#								Initialization
# -------------------------------------------------------------------------------

mutable struct Countries_struct
	index::Int64
	name::String

    language::Tuple{String, Int64, Int64}  # (name, lexical_density, semantic_precision)

	score::Float64
	coordinates::Tuple{Float64, Float64}
	neighbors::Vector{String}
end

	
function initialize_countries(countrie) 

    countrie[0] = Countries_struct(0, "Brazil", ("Portuguese", 70, 60), 0.0, (0.0, 0.0), String[])
    countrie[1] = Countries_struct(1, "Argentina", ("Spanish", 65, 70), 0.0, (0.0, 0.0), String[])
    countrie[2] = Countries_struct(2, "Chile", ("Spanish", 68, 75), 0.0, (0.0, 0.0), String[])

end

function set_neighbors(countrie)

	countrie[0].neighbors = ["Argentina", "Chile"]
	countrie[1].neighbors = ["Brazil", "Chile"]
	countrie[2].neighbors = ["Brazil", "Argentina"]

end

function create_map(countries)

	# goal to set coordinates and neighbors of each country
end

# -------------------------------------------------------------------------------
#								Payoff calculation
# -------------------------------------------------------------------------------

function score_calculation(countrie, i) 

	A = 0.5
	B = 0.5

	countrie[i].score = A * countrie[i].language[2] + B * countrie[i].language[3]

	#@printf "%d \n" countries[i].score
end	



# -------------------------------------------------------------------------------
#								Update rule
# -------------------------------------------------------------------------------

function update_rule(countrie, i, j)

	Δ = countrie[j].score-countrie[i].score
	β = 1/0.1
	Wxy = 1.0/(1.0 + exp(-β*Δ))
	a = rand()

	if Wxy > a
		countrie[i].language = countrie[j].language
	end
end

# -------------------------------------------------------------------------------
#								Monte Carlo Step
# -------------------------------------------------------------------------------
function mcs(countrie)

	for n in 0:N-1

		# selecionar país I
		# selecionar país dentro de countries.neighbors j
	
		score_calculation(countrie, i)
		score_calculation(countrie, j)
		
		update_rule(countrie, i, j)		
	end
end

# -------------------------------------------------------------------------------
#								Time dynamics
# -------------------------------------------------------------------------------
function time_dynamics(countrie)

	for t in 1:tmax
		mcs(countrie)   	
    end
end

# -------------------------------------------------------------------------------
#								Save data
# -------------------------------------------------------------------------------
function save_data(variable, i)

	t=1:tmax
	directoryPath = string(@__DIR__, "/data/")
	filename = @sprintf("%sdata%d_p%.3f.dat",directoryPath, i, r)
	writedlm(filename,[t variable])
end

# -------------------------------------------------------------------------------
#								Main
# -------------------------------------------------------------------------------
function main(n,r,K)

	countrie = OffsetArray{Countries_struct, 1}(undef, 0:N-1) 
	variable = OffsetArray{Float64}(undef, 0:tmax)

	variable .= 0

	initialize_countries(countrie)
	set_neighbors(countrie)
	create_map(countrie)
	time_dynamics(countrie, variable)
	save_data(variable, i)
end

# -------------------------------------------------------------------------------
#								Parameters
# -------------------------------------------------------------------------------

const tmax=10^4

Random.seed!() # put number inside () to fix seed
main()

# tarefas
# organizar dados wals
# criar coordenadas mapa topologico
# subdividir os paises