DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

libcxxwrap=$(julia -e 'using Pkg; Pkg.activate("./"); using CxxWrap; print(CxxWrap.prefix_path());')
rm -rf $DIR/lib/ot-build
mkdir $DIR/lib/ot-build
cd $DIR/lib/ot-build
echo $libcxxwrap
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$libcxxwrap ../ot
cmake --build . --config Release
rm -rf $DIR/lib/ot-build
