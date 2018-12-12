#Creates a random sequence of ABCD of length chars
#LIMITATIONS: only goes A-D currently
function rand_seq(chars)
  seq = ""
  for i = 1:chars
    r = abs(rand(Int) % 4)
    if (r == 0)
      seq = seq * "A"
    elseif (r == 1)
      seq = seq * "B"
    elseif (r == 2)
      seq = seq * "C"
    else
      seq = seq * "D"
    end
  end
  return seq
end

#Writes the genotypes for each bug
function genotypes(init_chars, coding_len)
  #Bug header
  fheader = ""
  for i in 1:9
    fheader = fheader*"pos,"
  end
  for i in 1:9
    fheader = fheader*"neg,"
  end
  fheader = fheader*"coding"

  #Phenotype header
  gheader = "phenotype"

  #Open and writes 4 bug files
  for m in 1:5
    f = open("bug$m.csv", "w")
    println(f, fheader)
    g = open("bug$m.phenotype.csv", "w")
    println(g, gheader)
    for i in 1:100
      genes = ""
      for j in 1:18
        genes = genes*rand_seq(init_chars)*","
      end
      codingseq = rand_seq(coding_len)
      #add coding sequence to the end of the genotype
      println(f, genes*codingseq)
      #add coding sequence to phenotype (initial state - all genes are expressed)
      println(g, codingseq)
    end
    close(f)
    close(g)
  end
end

function environment(coding_len)
  #15 environments - 6 input, 100 have to have, 100 must not have
  #all length coding_len

  #header
  header = ""
  for i in 1:6
    header = header*"input,"
  end
  for i in 1:100
    header = header*"HTH,"
  end
  for i in 1:99
    header = header*"MNH,"
  end
  header = header*"MNH"

  f = open("environment.csv", "w")
  println(f, header)
  for i in 1:15
    env = ""
    for i in 1:205
      env = env*rand_seq(coding_len)*","
    end
    println(f, env*rand_seq(coding_len))
  end
  close(f)
end

function main()
  init_chars = 4 #number of characters in each control sequence
  coding_len = 5 #length of each coding DNA (and environmental length)
  genotypes(init_chars, coding_len)

  environment(coding_len)
end

main()
