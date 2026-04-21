using Shapefile
using DataFrames
using CSV

# -------------------------------------------------------------------
# INPUT
# -------------------------------------------------------------------

shapefile_path = "ne_110m_admin_0_countries.shp"

# -------------------------------------------------------------------
# LOAD SHAPEFILE
# -------------------------------------------------------------------

table = Shapefile.Table(shapefile_path)

# -------------------------------------------------------------------
# PROCESS COUNTRIES
# -------------------------------------------------------------------

names = String[]
isos  = String[]
lats  = Float64[]
lons  = Float64[]

for row in table

    name = row.ADMIN
    iso  = row.ADM0_A3

    # -----------------------------------------
    # FILTER INVALID COUNTRIES
    # -----------------------------------------
    if iso == "-99"
        continue
    end

    if name == "Antarctica"
        continue
    end

    geom = row.geometry

    # -----------------------------------------
    # EXTRACT ALL POINTS (handles multipolygons)
    # -----------------------------------------
    xs = Float64[]
    ys = Float64[]

    for poly in geom.parts
        for point in poly
            push!(xs, point.x)
            push!(ys, point.y)
        end
    end

    # -----------------------------------------
    # CENTROID (simple average)
    # -----------------------------------------
    lon = mean(xs)
    lat = mean(ys)

    # -----------------------------------------
    # STORE
    # -----------------------------------------
    push!(names, name)
    push!(isos, iso)
    push!(lats, lat)
    push!(lons, lon)
end

# -------------------------------------------------------------------
# SAVE CSV
# -------------------------------------------------------------------

df = DataFrame(
    name = names,
    iso  = isos,
    lat  = lats,
    lon  = lons
)

CSV.write("countries.csv", df)

println("Saved countries.csv with $(nrow(df)) countries")