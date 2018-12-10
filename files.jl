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
  #Open and writes 4 bug files
  for m in 1:4
    f = open("bug$m.csv", "w")
    g = open("bug$m.phenotype.csv", "w")
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
  f = open("environment.csv", "w")
  for i in 1:15
    env = ""
    for i in 1:105
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
