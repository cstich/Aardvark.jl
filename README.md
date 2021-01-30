# Aardvark.jl
This library calculates the [Earth Mover Distance](https://en.wikipedia.org/wiki/Earth_mover%27s_distance) between two one-dimensional vectors with a custom cost matrix. 
It uses the network simplex algorithm to compute the cost of the optimal transport problem and is the fastest implementation of EMD, I have found so far. 
However, in certain situations the network simplex algorithm fails to converge to a solution where one exists.
I originally based this project on the Cython wrapper from [POT](https://github.com/PythonOT/POT/tree/master/ot/lp/). 
However, it seems in the meantime the people writing the original code have setup up their own [repository](https://github.com/nbonneel/network_simplex) as well.

In any case the original code is based on this paper:
> @article{BPPH11,
>    author = {Bonneel, Nicolas and van de Panne, Michiel and Paris, Sylvain and Heidrich, Wolfgang},  
>    title = {{Displacement Interpolation Using Lagrangian Mass Transport}},  
>    journal = {ACM Transactions on Graphics (SIGGRAPH ASIA 2011)},  
>    volume = {30},  
>    number = {6},  
>    year = {2011},  
> }

Please cite the paper if you use this package for a publication.

## Project Status
This project is built agains `julia 1.5` and in an early alpha version. 

## Build

Until I figure out how to build the C++ dependencies with `BinaryBuilder.jl` in a way that lets me use this library on `NixoOS` as well, you need to compile the C++ code yourself. That means a somehwat recent `cmake` needs to be in your environment when building this package. You also need `openMp` when compiling. On the plus side, this enables automatic multi-threading.

## Usage
````
using Aardvark
using Distances
````
You can just call `emd` with two vectors and the cost matrix:
````
a = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
b = reverse(a)
M = pairwise(Euclidean(), transpose(a), dims=2)
emd(a, b, M)
````
Alternatively you can also define, a `Metric`:
````
D = EMD(M)
D(a, b)
````
## TODO
1) Update source [X]
2) Find out how to ship compiled version that works on Nixos [ ]
3) Do a benchmark [ ]
4) Support more dimensions [?]
5) Example of when the network simplex algorithm fails [ ] 
6) Write tests [ ]


