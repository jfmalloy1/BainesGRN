using DataFrames
using CSV

#checks to see how many times the coding sequence appears in positive and negative controls
function check_control(codingseq)
    sum = 0

    for row in CSV.File("bug1.csv")
        controls = []


        properties = map(Symbol, filter(s -> occursin(r"^pos", s), map(string, propertynames(row))))
        for name in properties
            if occursin(Regex(getproperty(row, name)), codingseq)
                sum = sum + 1
            end
        end
        properties = map(Symbol, filter(s -> occursin(r"^neg", s), map(string, propertynames(row))))
        for name in properties
            if occursin(Regex(getproperty(row, name)), codingseq)
                sum = sum - 1
            end
        end
    end
    println("Sum is $sum")
end

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
        #Run 1, Step A: Checks if the coding sequence is found in the environment
        if row.coding in env
            phenotype = phenotype*row.coding*"\n"

        #Run 1, Step B: if not, check control elements with phenotype
        else
            check_control(row.coding)
        end
    end


    #TODO: Replace phenotype file with updated phenotype
    println("Phenotype is", phenotype)
end

function main()
    #pick environment (1-15)
    env = rand(Int) % 15
    run1(env + 1)
end

main()
