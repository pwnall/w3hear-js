#!/bin/bash
#
# Builds a pocketsphinx model.
#
# The following environment variables can be used to change the built model.
#   * MODEL_NAME - the name of the model in the distribution; this should be a
#                  language, like "en"
#   * HMM_PATH - points to the directory holding the HMM model files
#   * DIC_FILE - points to the dictionary file (.dic)
#   * DMP_FILE - points to the statistical language model file (.DMP)

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Inputs with default values.
: ${MODEL_NAME:="digits"}
: ${HMM_PATH:="third_party/pocketsphinx/model/hmm/en/tidigits"}
: ${DIC_FILE:="third_party/pocketsphinx/model/lm/en/tidigits.dic"}
: ${DMP_FILE:="third_party/pocketsphinx/model/lm/en/tidigits.DMP"}

# Point the build system to our packaged fastcomp and emscripten.
export LLVM="$PWD/build/fastcomp/build/bin"
export EMSCRIPTEN="$PWD/third_party/emscripten"
export SPHINX="$PWD/build/sphinx/build"

rm -rf "build/sphinx_models/$MODEL_NAME"
mkdir -p "build/sphinx_models/$MODEL_NAME/js"
mkdir -p "build/sphinx_models/$MODEL_NAME/models/$MODEL_NAME"
cp $DIC_FILE "build/sphinx_models/$MODEL_NAME/models/$MODEL_NAME.dic"
cp $DMP_FILE "build/sphinx_models/$MODEL_NAME/models/$MODEL_NAME.DMP"
# Copy all the files in a path that may have spaces.
OLD_PWD="$PWD"
cd "$HMM_PATH"
cp * "$OLD_PWD/build/sphinx_models/$MODEL_NAME/models/$MODEL_NAME/"
cd "$OLD_PWD"


# Build JS files.
cd "build/sphinx_models/$MODEL_NAME/models"
python "$EMSCRIPTEN/tools/file_packager.py" \
    "$SPHINX/build/pocketsphinx.js" \
    --embed **/* * \
    "--js-output=../$MODEL_NAME.js"
cd ../../../..

mkdir -p lib/sphinx/models
cp "build/sphinx_models/$MODEL_NAME/$MODEL_NAME.js" lib/sphinx/models/
