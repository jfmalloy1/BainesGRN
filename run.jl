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
        if (!ismissing(getproperty(row, name)) && occursin(Regex(getproperty(row, name)), seq))
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

#Randomly picks a letter (A-D)
#Returns the letter that was picked
function pick_letter()
    r = rand(1:4)
    if r == 1
        return 'A'
    elseif r == 2
        return 'B'
    elseif r == 3
        return 'C'
    else
        return 'D'
    end

end

#Take in a string, change a single letter in it
#s: the string to be changed
function change(s)
    #random position that will be changed
    p = rand(1:length(s))

    #randomly change to 1:4
    r = rand(1:4)
    s = collect(s)
    s[p] = pick_letter()
    s = join(s)
    return s
end

#Add a single letter in a random position in the string
#s: the sting to be changed
function add_letter(s)
    #random position (letter will be added on at the end)
    p = rand(1:length(s))
    c = pick_letter()

    #add c to the middle of the string (split into first half, last half on the randomly chosen position)
    fh = s[1:p]
    lh = s[p+1:end]
    s = fh*c*lh
    return s
end

#Delete a single letter from a string, unless it fully deletes a sequence
#s: the string to be changed
function delete_letter(s)
    if length(s) == 1
        return s
    else
        #Letter at position p will be deleted
        p = rand(1:length(s))
        s = collect(s)
        deleteat!(s, p)
        s = join(s)
        return s
    end
end

#Run 4: Mutate the genome of each bug according to pre-defined probabilities
#bug: the name of the bug file to mutate
#Pc: probability of changing a letter
#Pa: probability of adding a letter
#Pd: probability of deleting a letter
#PD: probability of deleting entire sequence (does not apply to coding sequence)
function run4(bug, Pm, PD)
    data = CSV.read(bug)

    #array of column names
    cols = names(data)

    for i in 1:length(cols)
        for j in 1:length(data[cols[i]])
            #check if there is a mutation
            if (rand(Float64) < Pm)
                #change (1), addition (2), deletion (3)
                c = rand(1:3)
                #randomly pick a letter, change it to A, B, C, D
                if (c == 1 && !ismissing(data[cols[i]][j]))
                    data[cols[i]][j] = change(data[cols[i]][j])
                #randomly pick a position, add a letter following it
                elseif (c == 2 && !ismissing(data[cols[i]][j]))
                    data[cols[i]][j] = add_letter(data[cols[i]][j])
                #randomly pick a position, delete that letter
                elseif (c == 3 && !ismissing(data[cols[i]][j]))
                    data[cols[i]][j] = delete_letter(data[cols[i]][j])
                end
            end
            #check if there is a deletion (NOT in coding sequence)
            if (rand(Float64) < PD && i != length(cols))
                data[cols[i]][j] = ""
            end
        end
    end
    #overwrite bug file
    CSV.write(bug, data)
end

function main()
    #output file
    f = open("fitness.csv", "w")

    #pick environment (1-15)
    env = abs((rand(Int) % 15) + 1)
    println("Env is: $env")
    #all bugs
    bugs = []
    for i in 1:20
        bug = "bug$i.csv"
        push!(bugs, bug)
    end

    for i in 1:20
        #time step to data file
        print(f, i)

        println("Run$i")

        #Max fitness calculation
        max = -Inf
        max_bug = bugs[1]

        #loop through all bugs
        for bug in bugs
            run1(env, bug)
            fitness = run2(env, bug[1:end-4])
            if fitness > max
                max = fitness
                max_bug = bug
            end
            run4(bug, .5, .05)
            #Fitness output
            println("Fitness of $bug is $fitness")
            print(f, ",$fitness")

        end
        #bug with highest fitness randomly switched with a bug
        r = rand(1:length(bugs))
        str = "Replacement: "*bugs[r]*" replaced with $max_bug"
        println(str)
        if bugs[r] != max_bug
            Base.Filesystem.cp(max_bug, bugs[r], force=true)
        end
        #Next line in data file
        println(f)
    end
    close(f)
end

main()
