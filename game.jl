# -------------------------------------------------------------------------------
#								Packages
# -------------------------------------------------------------------------------

using OffsetArrays, StructArrays, Printf, DelimitedFiles, Statistics, Random


# -------------------------------------------------------------------------------
#								Initialization
# -------------------------------------------------------------------------------

mutable struct Countries_struct
	iso::String
	name::String

	# (name, lexical_density, semantic_precision)
    language::Tuple{String, Int64, Int64}  

	score::Float64
	coordinates::Tuple{Float64, Float64}
	area::Float64
	neighbors::Vector{String}
end

function initialize_countries()

	countries_df = CSV.read("countries.csv", DataFrame)
    global n = nrow(countries_df)

    countrie = Vector{Countries_struct}(undef, n)

    for i in 1:n
        iso = countries_df.iso[i]
        name = countries_df.name[i]
        lat = countries_df.lat[i]
        lon = countries_df.lon[i]
		lang = countries_df.language[i]
		area = countries_df.area[i]

        countrie[i] = Countries_struct(
            iso,
            name,
            (lang, 0, 0),  
            0,
            (lat, lon),
			area,
            String[]
        )
    end

    return countrie
end

function set_neighbors(countrie)

	borders_df = CSV.read("borders.csv", DataFrame)
	rows = nrow(borders_df)

    for i in 1:rows

		neighbor = borders_df.iso2[i]
		link = borders_df.contig[i]

		if link == 1
			push!(countrie[i].neighbors, neighbor)
		end
    end
end

function create_map(countrie)

	# goal to set coordinates and neighbors of each country
end

# -------------------------------------------------------------------------------
#								Payoff calculation
# -------------------------------------------------------------------------------
function score_calculation(countrie, i) 

	A = 0.5
	B = 0.5

	# aprimorar aqui
	# talvez considerar semelhanca entre vizinhos ou area
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
		i = rand(1:n)
		j = rand(1:length(countrie[i].neighbors))
	
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
function main()

	variable = OffsetArray{Float64}(undef, 0:tmax)
	variable .= 0

	countrie = initialize_countries()
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