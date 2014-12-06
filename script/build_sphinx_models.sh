#!/bin/bash
#
# Builds the pocketsphinx models.

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Big generic-purpose English model.
MODEL_NAME=en \
    HMM_PATH=third_party/pocketsphinx/model/hmm/en_US/hub4wsj_sc_8k \
    DIC_FILE=third_party/pocketsphinx/model/lm/en_US/cmu07a.dic \
    DMP_FILE=third_party/pocketsphinx/model/lm/en_US/wsj0vp.5000.DMP \
    ./script/build_sphinx_model.sh

# Tiny model for testing purposes that covers digits.
MODEL_NAME=digits \
    HMM_PATH=third_party/pocketsphinx/model/hmm/en/tidigits \
    DIC_FILE=third_party/pocketsphinx/model/lm/en/tidigits.dic \
    DMP_FILE=third_party/pocketsphinx/model/lm/en/tidigits.DMP \
    ./script/build_sphinx_model.sh

