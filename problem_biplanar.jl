using Random
using LinearAlgebra
using GraphPlot
using PyCall
using Graphs
using SimpleGraphAlgorithms
using SimpleGraphs
using SimpleGraphConverter
ENV["PYTHON"] = "C:/Python39/python.exe"  # Replace with the actual path
using Pkg
Pkg.build("PyCall")
sys = pyimport("sys")
push!(sys."path", "/Users/PerWagenius/transformers_math_experiments/")

# Import the Python module
py_module = pyimport("pythonfnsforbiplanarjl")

const N = 20

function convert_adjmat_to_string(adjmat::Matrix{Int8})::String
    entries = []

    # Collect entries from the upper diagonal of the matrix
    for i in 1:N-1
        for j in i+1:N
            push!(entries, string(adjmat[i, j]))
        end
        push!(entries, ",")
    end

    # Join all entries into a single string
    return join(entries)
end
function convert_adjmat_to_string(adjmat::Matrix{Int64})::String
    entries = []

    # Collect entries from the upper diagonal of the matrix
    for i in 1:N-1
        for j in i+1:N
            push!(entries, string(adjmat[i, j]))
        end
        push!(entries, ",")
    end

    # Join all entries into a single string
    return join(entries)
end

function greedy_search_from_startpoint(db, obj::String)::Vector{String}
    #take in the imput (string) and make it into an adj matrix
    num_commas = count(c -> c == ',', obj)
    if num_commas == N - 1 #we've got the right size graph
        initMatrix = zeros(Int8, N, N)
        # Fill the upper triangular matrix
        index = 1
        for i in 1:N-1
            for j in i+1:N
                while obj[index] == ','
                    index += 1
                end
                #println(obj[index])
                initMatrix[i, j] = parse(Int8, obj[index])  # Convert character to integer
                initMatrix[j, i] = initMatrix[i, j]  # Make the matrix symmetric
                index += 1
            end
        end
    else #we don't have an input graph of the right side so just use an empty graph
        initMatrix = zeros(Int8, N, N)
    end
    #Get the maximal biplanar graph via the python function
    #println(initMatrix)
    adjmat=py_module.maximize_biplanar_components(initMatrix)
    return [convert_adjmat_to_string(adjmat)]
    # Now that we have 'adjmat', sample four random permutations
    permuted_adjmats = []
    for _ in 1:4
        perm = randperm(N)  # Generate a random permutation
        permuted_adjmat = adjmat[perm, perm]  # Apply the permutation to rows and columns
        push!(permuted_adjmats, permuted_adjmat)
    end
    return [convert_adjmat_to_string(permuted_adjmat) for permuted_adjmat in permuted_adjmats]
end
function reward_calc(obj::String)::REWARD_TYPE
    """
    Function to calculate the reward of a final construction
    (E.g. number of edges in a graph, etc)
    """
    g = SimpleGraph(N)
    index = 1
    for i in 1:N-1
        for j in i+1:N
            while obj[index] == ','
                index += 1
            end
            if parse(Int8, obj[index]) in [1,2]  # Convert character to integer
                add_edge!(g, i, j)
            end
            index += 1
        end
    end
    return chromatic_number(UG(g))
end
function empty_starting_point()::String
    """
    If there is no input file, the search starts always with this object
    (E.g. empty graph, all zeros matrix, etc)
    """
    adjmat = zeros(Int8, N, N)
    return convert_adjmat_to_string(adjmat)
end 
#testingFns
#= println("empty_starting_point")
println(empty_starting_point())
println("maximize_biplanar_components")
obj="222212211,21111111,2221111,112221,12111,2111,212,21,2, "
num_commas = count(c -> c == ',', obj)
if num_commas == N - 1 #we've got the right size graph
    println("rightsize!")
    initMatrix = zeros(Int8, N, N)
    # Fill the upper triangular matrix
    let
        loclindex::Int64 = 1
        for i in 1:N-1
            for j in i+1:N
                while obj[loclindex] == ','
                    loclindex += 1
                end
                #println(obj[loclindex])
                initMatrix[i, j] = parse(Int8, obj[loclindex])  # Convert character to integer
                initMatrix[j, i] = initMatrix[i, j]  # Make the matrix symmetric
                loclindex += 1
            end
        end
    end
else #we don't have an input graph of the right side so just use an empty graph
    initMatrix = zeros(Int8, N, N)
end
#Get the maximal biplanar graph via the python function
println(initMatrix)
adjmat=py_module.maximize_biplanar_components(initMatrix)
println(adjmat)
println(convert_adjmat_to_string(adjmat)) =#