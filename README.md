# W3Ear

Infrastructure for speech recognition in JavaScript.


## Prerequisites

[enscripten](https://github.com/kripken/emscripten) requires
[CMake](http://www.cmake.org/),
[Git](http://git-scm.com/),
[python](https://www.python.org/),
[node.js](http://nodejs.org/).

We recommend [nvm](https://github.com/creationix/nvm) for installing and
managing node.js. The following commands will install the other packages on
OSX.


```bash
brew install cmake
brew install git
brew install python

# Install nvm and use it to install node.js.
```

## Setup

```bash
git clone
git submodule init
git submodule update
./script/build_fastcomp.sh
./script/build_sphinx.sh
```
