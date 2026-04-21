
using XLSX, CSV, DataFrames

file = "$( @__DIR__ )/datasets/geo_cepii.xlsx"   

# -------------------------------------------------------------------
# READ EXCEL
# -------------------------------------------------------------------

xf = XLSX.readxlsx(file)
#println(XLSX.sheetnames(xf))
sh = xf["geo_cepii"]
df = DataFrame(XLSX.gettable(sh))

println(names(df))

# -------------------------------------------------------------------
# SELECT & RENAME COLUMNS
# (adjust names if needed after inspection)
# -------------------------------------------------------------------
name_col = :country
iso_col  = :iso3
lat_col  = :lat
lon_col  = :lon
area_col = :area

# -------------------------------------------------------------------
# BUILD data DATAFRAME
# -------------------------------------------------------------------

data = DataFrame(
    name = df[!, name_col],
    iso  = df[!, iso_col],
    lat  = df[!, lat_col],
    lon  = df[!, lon_col],
    area = df[!, area_col]
)

# -------------------------------------------------------------------
# SAVE CSV
# -------------------------------------------------------------------

sort!(data, :name)
CSV.write("countries.csv", data)
println("Saved countries.csv with $(nrow(data)) countries")

