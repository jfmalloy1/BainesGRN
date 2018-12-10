#Creates a random sequence of ABCD of length chars
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
function genotypes()
  n = 4 #number of initial characters

  #Open and writes 4 bug files
  for m in 1:4
    #filename = "bug" * n * ".txt"
    #println(filename)
    f = open("bug$m.txt", "w")
    for i in 1:100
      genes = ""
      for j in 1:18
        genes = genes*rand_seq(n)*","
      end
      println(f, genes*rand_seq(5))
    end
    close(f)
  end
end

function main()
  genotypes()
end

main()
