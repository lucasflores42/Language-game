# -------------------------------------------------------------------------------
#								Packages
# -------------------------------------------------------------------------------

using OffsetArrays, StructArrays, Printf, DelimitedFiles, Statistics, Random, CSV, DataFrames


# -------------------------------------------------------------------------------
#								Initialization
# -------------------------------------------------------------------------------

mutable struct Countries_struct
	index::Int64
	iso::String
	name::String

	# (name, lexical_density, semantic_precision)
    #language::Tuple{String, Int64, Int64, Int64, Int64, Int64}  
	language::Vector{Any}

	score::Float64
	coordinates::Tuple{Float64, Float64}
	area::Float64
	neighbors::Vector{String}
end

function initialize_countries()

	countries_df = CSV.read("countries.csv", DataFrame)
    global n = nrow(countries_df)

    country = Vector{Countries_struct}(undef, n)

    for i in 1:n
        iso = countries_df.iso[i]
        name = countries_df.name[i]
        lat = countries_df.lat[i]
        lon = countries_df.lon[i]
		lang = countries_df.lang[i]
		area = countries_df.area[i]

        country[i] = Countries_struct(
			i,
            iso,
            name,
            [lang, 0, 0, 0, 0, 0],
            0,
            (lat, lon),
			area,
            String[]
        )
    end

    return country
end

function set_neighbors(country)

	borders_df = CSV.read("borders.csv", DataFrame)
	rows = nrow(borders_df)

    for i in 1:rows

		central = borders_df.iso1[i]
		neighbor = borders_df.iso2[i]
		link = borders_df.contig[i]

		# countries loop
		for j in 1:n
			if link == 1 && country[j].iso == central
				push!(country[j].neighbors, neighbor)
			end
		end
    end
end

function set_language_features(country)

	features_df = CSV.read("language_features.csv", DataFrame)
	rows = nrow(features_df)

	# features loop
	for i in 1:rows

		language = features_df.language[i]
		feature = features_df.parameter_id[i]
		feature_list = ["81A", "85A", "49A", "30A", "1A"] # same from data3.jl

		# countries loop
		for j in 1:n
			if country[j].language[1] == language
				if feature == feature_list[1]
					country[j].language[2] = features_df.value_number[i]
				elseif feature == feature_list[2]
					country[j].language[3] = features_df.value_number[i]
				elseif feature == feature_list[3]
					country[j].language[4] = features_df.value_number[i]
				elseif feature == feature_list[4]
					country[j].language[5] = features_df.value_number[i]
				elseif feature == feature_list[5]
					country[j].language[6] = features_df.value_number[i]
				end
			end
		end
	end

end

function create_map(country)

	# goal to set coordinates and neighbors of each country
end

# -------------------------------------------------------------------------------
#								Payoff calculation
# -------------------------------------------------------------------------------
function score_calculation(country, i) 

	similarity = 0
	complexity = 0

	n_neighbors = length(country[i].neighbors)
	n_features = length(country[i].language) - 1

	for j in 1:n_neighbors
		for i in 2:n_features
			# similarity
			if country[i].language[i] == country[j].language[i]
				similarity += 1
			end
			# complexity
			complexity += country[i].language[i]
		end
	end

	similarity /= n_neighbors * n_features
	complexity /= n_neighbors * n_features

	A = 0.5
	B = 0.5

	country[i].score = A * similarity + B * complexity
	#@printf "%d \n" countries[i].score
end	



# -------------------------------------------------------------------------------
#								Update rule
# -------------------------------------------------------------------------------
function update_rule(country, i, j)

	Δ = country[j].score-country[i].score
	β = 1/0.1
	Wxy = 1.0/(1.0 + exp(-β*Δ))
	a = rand()

	if Wxy > a
		country[i].language = country[j].language
	end
end

# -------------------------------------------------------------------------------
#								Monte Carlo Step
# -------------------------------------------------------------------------------
function mcs(country, iso_to_index)

	for k in 1:length(country)

		# selecionar país I
		# selecionar país dentro de countries.neighbors j
		i = rand(1:n)
		neighbors = country[i].neighbors

		if isempty(neighbors)
            continue
        end
		
		j_name = rand(neighbors)
		j_index = iso_to_index[j_name]

		score_calculation(country, i)
		score_calculation(country, j_index)
		
		update_rule(country, i, j_index)		
	end
end

# -------------------------------------------------------------------------------
#								Time dynamics
# -------------------------------------------------------------------------------
function time_dynamics(country, iso_to_index)

	for t in 1:tmax
		mcs(country, iso_to_index)   	
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

	country = initialize_countries()
	set_neighbors(country)
	set_language_features(country)
	#create_map(country)
	iso_to_index = Dict(c.iso => c.index for c in country)
	time_dynamics(country, iso_to_index)
	#save_data(variable, i)
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