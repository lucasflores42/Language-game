using CSV, DataFrames

languages = CSV.read("$( @__DIR__ )/datasets/raw-wals/language.csv", DataFrame)
parameters = CSV.read("$( @__DIR__ )/datasets/raw-wals/parameter.csv", DataFrame)
valuesets = CSV.read("$( @__DIR__ )/datasets/raw-wals/valueset.csv", DataFrame)
values = CSV.read("$( @__DIR__ )/datasets/raw-wals/value.csv", DataFrame)
domainelements = CSV.read("$( @__DIR__ )/datasets/raw-wals/domainelement.csv", DataFrame)

selected = ["81A", "85A", "49A", "30A", "1A"]

# filter selects rows that satisfy the condition
params_sel = filter(row -> row.id in selected, parameters)

vs = innerjoin(valuesets, params_sel,
    on = :parameter_pk => :pk, # valuesets.parameter_pk == params_sel.pk
    makeunique = true
)
df = innerjoin(vs, values,
    on = :pk => :valueset_pk,
    makeunique = true
)
df = innerjoin(df, domainelements,
    on = :domainelement_pk => :pk,
    makeunique = true
)
df = innerjoin(df, languages,
    on = :language_pk => :pk,
    makeunique = true
)

final = DataFrame(
    language       = df[!, :name_3],   # languages.name
    parameter_id   = df[!, :id_1],     # parameters.id
    parameter_name = df[!, :name],     # parameters.name
    value_number   = df[!, :number],    # numeric category
    value_name     = df[!, :name_2]    # domainelement.name (actual value)
)

#println(names(df))
#println(names(final))
CSV.write("language_features.csv", final)


# -------------------------------------------------------------------
# WALS TABLE STRUCTURE (REFERENCE)
# -------------------------------------------------------------------

# ---------------------------
# parameters.csv
# ---------------------------
# pk | id  | name
# -------------------------------
# 4  | 4A  | Voicing in Plosives
# 2  | 2A  | Vowel Inventory Size
# 49 | 49A | Number of Cases
#
# used id, name


# ---------------------------
# languages.csv
# ---------------------------
# pk  | name
# ----------------
# 100 | Abkhaz
# 101 | Ainu
# 102 | Albanian
#
# used: name


# ---------------------------
# valueset.csv
# ---------------------------
# pk | id      | language_pk | parameter_pk
# -----------------------------------------
# 1  | 4A-abk  | 100         | 4
# 2  | 4A-ain  | 101         | 4
# 3  | 2A-abk  | 100         | 2
#
# used: pk (to connect with value.csv)


# ---------------------------
# value.csv
# ---------------------------
# pk | valueset_pk | domainelement_pk
# -----------------------------------
# 1  | 1           | 15
# 2  | 2           | 14
# 3  | 3           | 6
#
# used: domainelement_pk (to connect with domainelement.csv)


# ---------------------------
# domainelement.csv
# ---------------------------
# pk | id    | name                                 | parameter_pk | number
# -----------------------------------------------------------------------
# 14 | 4A-1  | No voicing contrast                  | 4            | 1
# 15 | 4A-2  | In plosives alone                    | 4            | 2
# 16 | 4A-3  | In fricatives alone                  | 4            | 3
# 17 | 4A-4  | In both plosives and fricatives      | 4            | 4
# 6  | 2A-1  | Small (2-4)                          | 2            | 1
#
# used: name, number