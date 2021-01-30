# This shell gives you the nix development environment for the pacakge
# To drop into a nix shell use: nix-shell default.nix

with import <nixpkgs> {};

let
  
  myPackages = pythonPackages: with pythonPackages; [
    pyemd
    ];
  python-stuff = python3.withPackages myPackages;

  extraLibs = [
  ];

  libPath = lib.makeLibraryPath [
  ];

in

# pkgs.mkShell {
  pkgs.stdenv.mkDerivation {
  name = "aardvark-julia";
  buildInputs = with pkgs; [
    julia
    python-stuff
    # Apparently we need a curl install here or otherwise this happens:
    # https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/527
    cmake
    curl 
    git
    gitRepo
    llvmPackages.openmp
    zlib
     ];

  shellHook = ''
    WORKING_DIR=$PWD

    rm -f env_julia
    ln -s ${julia} $WORKING_DIR/env_julia

    # Set PYTHONPATH so that PyCall in julia finds the relevant packages
    # FIXME Find appropriate python version/pythonpath automatically
    export PYTHONPATH=${python-stuff}/lib/python3.8/site-packages/ 

    # Setup a local pip build directory
    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' \pip"
    # FIXME Find appropriate python version/pythonpath automatically
    export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.8/site-packages:$PYTHONPATH"
    unset SOURCE_DATE_EPOCH

    # Julia Threads
    NPROC=$(cat /proc/cpuinfo | grep processor | wc -l)
    export JULIA_NUM_THREADS=$((NPROC / 2))

    # The Cmake binary fails, so we have to build it from source
    # julia -e 'ENV["CMAKE_JL_BUILD_FROM_SOURCE"] = 1'
    export CMAKE_JL_BUILD_FROM_SOURCE=1

    # Re-build PyCall so it uses the correct python in /nix/store
    # julia -e 'ENV["PYTHON"]="${python-stuff}/bin/python"; using Pkg; Pkg.activate("./"); Pkg.build("PyCall")'
  '';
}
