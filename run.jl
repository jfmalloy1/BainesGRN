using DataFrames
using CSV

#checks to see how many times the coding sequence appears in positive and negative controls
function check_control(codingseq, phenotype, bug)
    sum = 0

    for row in CSV.File(bug)
        controls = []

        #add up positive controls
        properties = map(Symbol, filter(s -> occursin(r"^pos", s), map(string, propertynames(row))))
        for name in properties
            if occursin(Regex(getproperty(row, name)), codingseq)
                sum = sum + 1
            end
        end
        #subtract negative controls
        properties = map(Symbol, filter(s -> occursin(r"^neg", s), map(string, propertynames(row))))
        for name in properties
            if occursin(Regex(getproperty(row, name)), codingseq)
                sum = sum - 1
            end
        end
    end

    #add all expressed genes (sum of controls > 0) to the phenotype
    if (sum > 0)
        phenotype = phenotype*codingseq*"\n"
    end
    return phenotype
end

#builds new phenotype
function run1(env, bug)
    #If coding sequence is part of environment input (randomly picked), gene is expressed
    #CSV.File("bug1.csv") => CSV.File
    phenotype = "Phenotype\n"

    #read in environmental input
    e = CSV.read("environment.csv"; skipto = env, limit = 1)
    input = e[1:6]
    env =[]
    for r in eachcol(input, true)
        push!(env, (r[end][1]))
    end

    for row in CSV.File(bug)
        #Run 1, Step A: Checks if the coding sequence is found in the environment
        if row.coding in env
            phenotype = phenotype*row.coding*"\n"

        #Run 1, Step B: if not, check control elements with phenotype
        else
            phenotype = check_control(row.coding, phenotype, bug)
        end
    end


    #Replace phenotype file with updated phenotype
    bug = bug[1:4]
    f = open("$bug.phenotype.csv", "w")
    println(f, phenotype)
    close(f)
end

function main()
    #pick environment (1-15)
    bug = "bug1.csv"
    env = rand(Int) % 15
    run1(env + 1, bug)
end

main()
