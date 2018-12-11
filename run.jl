using DataFrames
using CSV

#Check if seq is found in row
#row: row of the CSV file (type: CSV.File row)
#seq: sequence to be found (type: String)
#reg: regex that matches the row name (type: String)
function occurs(row, seq, reg)
    sum = 0
    properties = map(Symbol, filter(s -> occursin(reg, s), map(string, propertynames(row))))
    for name in properties
        if occursin(Regex(getproperty(row, name)), seq)
            sum = sum + 1
        end
    end
    return sum
end
#checks to see how many times the coding sequence appears in positive and negative controls
function check_control(codingseq, phenotype, bug)
    sum = 0

    for row in CSV.File(bug)
        controls = []

        #add up positive controls
        sum = sum + occurs(row, codingseq, "pos")
        #subtract negative controls
        sum = sum - occurs(row, codingseq, "neg")
    end

    #add all expressed genes (sum of controls > 0) to the phenotype
    if (sum > 0)
        phenotype = phenotype*codingseq*"\n"
    end
    return phenotype
end

#Returns an array of strings containing a specific part of the environment
#Env: The random number telling which environment is present
#Start: The column which starts the array (either 1, 7, or 107)
#   1: input, 7: Have to Have, 107, Must Not Have
function read_env(env, start, stop)
    e = CSV.read("environment.csv"; skipto = env, limit = 1)
    input = e[start:stop]
    env_array =[]
    for r in eachcol(input, true)
        push!(env_array, (r[end][1]))
    end
    return env_array
end

#builds new phenotype
function run1(env, bug)
    #If coding sequence is part of environment input (randomly picked), gene is expressed
    #CSV.File("bug1.csv") => CSV.File
    phenotype = "Phenotype\n"

    #read in environmental input
    env_array = read_env(env, 1, 6)

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
    bug = bug[1:end-4]
    f = open("$bug.phenotype.csv", "w")
    println(f, phenotype)
    close(f)
end

#Run 2: Determine the fitness of a bug
#Count number of phenotype strings found in "Have to Have" section of environment
#Add them
#Subtact number of phenotype strings found in "Must Not Have" section
#Env: random number corrsponding to the current environment
#Bug: which bug is currently being evaluated
function run2(env, bug)

    fitness = 0
    #have to have sequences
    env_HTH = read_env(env, 7, 106)
    #must not have sequences
    env_MNH = read_env(env, 107, 206)

    #search through phenotype file
    for row in CSV.File("$bug.phenotype.csv")
        #skip missing data
        if typeof(row.Phenotype) == Missing
            continue
        end
        #add or subtract fitness as necessary
        if row.Phenotype in env_HTH
            fitness = fitness + 1
        elseif row.Phenotype in env_MNH
            fitness = fitness - 1
        end
    end
    return fitness
end

function main()
    #pick environment (1-15)
    env = (rand(Int) % 15) + 1

    #loop through all bugs
    bugs = ["bug1.csv", "bug2.csv", "bug3.csv", "bug4.csv"]
    for bug in bugs
        run1(env, bug)
        fitness = run2(env, bug[1:end-4])
        println("Fitness of $bug is $fitness")
    end
end

main()
