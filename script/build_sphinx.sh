#!/bin/bash
#
# Builds pocketsphinx with emscripten.

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

rm -rf build/sphinx
mkdir -p build

# Set up the pocketsphinx.js build tree and inject our Sphinx version.
cp -r third_party/pocketsphinx.js build/
mv build/pocketsphinx.js build/sphinx
rm -rf build/sphinx/sphinxbase
cp -r third_party/sphinxbase build/sphinx/
rm -rf build/sphinx/pocketsphinx
cp -r third_party/pocketsphinx build/sphinx/
mkdir -p build/sphinx/build

# Point the build system to our packaged fastcomp and emscripten.
export LLVM="$PWD/build/fastcomp/build/bin"
export EMSCRIPTEN="$PWD/third_party/emscripten"

# Build pocketsphinx with Emscripten.
cd build/sphinx/build
cmake .. \
    -DEMSCRIPTEN=1 \
    -DHMM_EMBED=OFF \
    -DCMAKE_TOOLCHAIN_FILE="$EMSCRIPTEN/cmake/Modules/Platform/Emscripten.cmake"
make -j4
cd ../../..

export SPHINX="$PWD/build/sphinx/build"
mkdir -p dist
cp "$SPHINX/pocketsphinx.js" lib/
