# W3Ear

Infrastructure for speech recognition in JavaScript.

## Motivation

Learning to code is both incredibly valuable, and incredibly tedious. When hours
of painful debugging are not rewarded by "a-ha!" moments, people become
discouraged and give up. Maximizing these small victories is important to easing
the learning process, especially for children. W3Ear makes programming more
exciting by giving your code ears.

We've chosen to tackle the Koding Global Virtual Hackathon's 2nd theme:
Introducing software development to a beginner. We want to help beginners stay
motivated as they run into obstacle after obstacle - a goal made difficult by
the fact that the code-writing process mostly involves writing text and
reading... more text. W3Ear shakes up the programming experience by letting you
run your code via voice commands. By taking advantage of the current state of
Web audio technologies, we hope to make coding a more rewarding experience.

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
npm install -g coffee-script
npm install
./script/build_fastcomp.sh
./script/build_sphinx.sh
```

```bash
cd node_modules/web-audio-api
npm install
```
