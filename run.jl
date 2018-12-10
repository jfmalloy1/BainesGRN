using DataFrames
using CSV

#builds new phenotype
function run1(env)
    #If coding sequence is part of environment input (randomly picked), gene is expressed
    #CSV.File("bug1.csv") => CSV.File
    phenotype = ""

    #read in environmental input
    e = CSV.read("environment.csv"; skipto = env, limit = 1)
    input = e[1:6]
    println("Input is: ", input)
    env =[]
    for r in eachcol(input, true)
        push!(env, (r[end][1]))
    end
    println("Env is: ", env)

    for row in CSV.File("bug1.csv")
        if row.coding in env
            phenotype = phenotype*row.coding*"\n"
        end
    end
    println("Phenotype is", phenotype)
end

function main()
    #pick environment (1-15)
    env = rand(Int) % 15
    run1(env + 1)
end

main()
