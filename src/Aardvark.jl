module Aardvark
    
    export EMD
    export emd

    using Distances


    struct EMD <: Distances.Metric
        ground_distance::AbstractArray{<:AbstractFloat, 2}
        max_iter::Integer
        raise_error::Bool
        function EMD(ground_distance, max_iter = 100000, raise_error=true)
            new(ground_distance, max_iter, raise_error)
        end
    end


    function (dist::EMD)(x, y)
        # I do not know how to pass a slice to Cxx so for now we need to make sure
        # we are not getting slices passed here
        return emd(Array(x), 
                   Array(y), 
                   dist.ground_distance, 
                   dist.max_iter)
    end


    module CppEMD
        using CxxWrap

        filename = joinpath(string(@__DIR__), "../lib/libEMD.so")
        @wrapmodule(filename)

        function __init__()
            @initcxx
        end
    end


    function emd(a::Array{<:AbstractFloat, 1}, 
                 b::Array{<:AbstractFloat, 1}, 
                 M::Array{<:AbstractFloat, 2}, 
                 max_iter::Integer=100000;
                 raise_error = true,
                 log = false)

        """
        raise_error: Whether to raise an error or to silently return -1.0


        Example of a problem without a solution
        a = [92  0.0130435
             93  0.00434783
             95  0.0347826
             96  0.0695652
             97  0.0652174
             98  0.0434783
             99  0.0434783
             100 0.926087]
        b = [92   0.0130435
             93   0.00434783
             95   0.0347826
             96   0.0623188
             97   0.0652174
             98   0.0869565
             99   0.0434783
             100  0.889855]
        a = sparsevec(a[:, 1], a[:, 2])
        b = sparsevec(b[:, 1], b[:, 2])
        ground_distance = hist.hist_to_distance_matrix(100)

        """
        
        # We can't pass views here
        # Cxx seems to take care of the C major format of the arrays though
        n1 = size(M)[1]
        n2 = size(M)[2]
        nmax = n1 + n2 - 1
        result_code = 0
        nG = 0
    
        cost = Ref(0.0)
        alpha = zeros(n1)
        beta = zeros(n2)
        G = zeros((1, 1))
        Gv = zeros()
        iG = zeros()
        jG = zeros()
    
        G = zeros((n1, n2))
    
        result_code = CppEMD.EMD_wrap(n1, n2, a, b, M, G, alpha, beta, cost, max_iter)
        if result_code == 0 && raise_error
            error("Problem not feasible.")
        elseif result_code == 0
            cost = Ref(-1.0)
        end
        if log
            return G, cost, alpha, beta, result_code
        else
            return cost[]
        end
end

end
