#!/bin/bash
#
# Builds fastcomp, emscripten's fork of LLVM/clang.

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

rm -rf build/fastcomp
mkdir -p build

# Set up the weird build tree described in the emscripten documentation.
#    http://kripken.github.io/emscripten-site/docs/building_from_source/building_fastcomp_manually_from_source.html#building-fastcomp-from-source-building
cp -r third_party/emscripten-fastcomp build/
mv build/emscripten-fastcomp build/fastcomp
mkdir -p build/fastcomp/tools
cp -r third_party/emscripten-fastcomp-clang build/fastcomp/tools
mv build/fastcomp/tools/emscripten-fastcomp-clang build/fastcomp/tools/clang
mkdir -p build/fastcomp/build

# Build fastcomp.
cd build/fastcomp/build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_TARGETS_TO_BUILD="X86;JSBackend" \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DCLANG_INCLUDE_EXAMPLES=OFF \
    -DCLANG_INCLUDE_TESTS=OFF
make -j4
cd ../../..

# Binaries are in build/fastcomp/build/bin
export LLVM="$PWD/build/fastcomp/build/bin"
export EMSCRIPTEN="$PWD/third_party/emscripten"

# Run emcc to have it generate the .emscripten file.
"$EMSCRIPTEN/emcc" --help
