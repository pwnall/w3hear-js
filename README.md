# w3hear-js

Infrastructure for speech recognition in JavaScript.

## Motivation

Learning to code is both incredibly valuable, and incredibly tedious. When hours
of painful debugging are not rewarded by "a-ha!" moments, people become
discouraged and give up. Maximizing these small victories is important to easing
the learning process, especially for children. w3hear-js makes programming more
exciting by giving your code ears!

We've chosen to tackle the Koding Global Virtual Hackathon's 2nd theme:
__Introducing software development to a beginner__. We want to help beginners
stay motivated as they run into obstacle after obstacle - a goal made difficult
by the fact that the code-writing process mostly involves writing text and
reading... more text. w3hear-js shakes up the programming experience by letting you
run your code via voice commands. For example, say you have a function
`draw_circle() {...}` in your web application that draws a circle. Using w3hear-js,
you can hook up that function to a voice command, like "Draw a circle!" Now you can
run your code by talking, rather than by typing!

By taking advantage of the current state of Web audio technologies, we hope to make
coding a more rewarding experience.

## Anatomy

The user's voice is first captured in the browser (__w3hear.js__). Speech
recognition is then handed off to a background thread (__w3hear_worker.js__)
that loads a Speech Recognition Engine. The engine contains a decoder and
various reference files. The references define all the sound units (phonemes)
that the engine will be expected to recognize, as well as the probabilistic
models (Hidden Markov Models) describing the likelihoods of phoneme combinations
(basically, valid words). The decoder refers to these models to determine the
word or phrase that most closely matches the input audio stream.

### w3hear.js

This file uses `getUserMedia()` from the WebRTC API and the
[Web Audio API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API)
to obtain permission to use the user's microphone.

### w3hear_worker.js

WHO AM I? WHAT YEAR IS THIS?


## Development Instructions

Read this section if you're interested in contributing to w3hear.js, or if you
want to build additional speech recognition engines or models into the library.


### Prerequisites

[enscripten](https://github.com/kripken/emscripten) requires
a C++ compiler toolchain,
[CMake](http://www.cmake.org/),
[Git](http://git-scm.com/),
[python](https://www.python.org/),
[node.js](http://nodejs.org/).

#### Mac OS X

We recommend [Homebrew](http://brew.sh/) for package management and
[nvm](https://github.com/creationix/nvm) for setting up node.js.  The Homebrew
setup process will walk you through installing the Command Line Tools for
Xcode, which provide a C++ compiler toolchain.

If you follow the recommendations, the following comands get the prerequisites
installed.

```bash
brew install cmake
brew install git
brew install python
nvm install 0.10
nvm use 0.10  # Issue this when working on w3hear.js

# If you set node 0.10 as a default, you don't need the command above.
nvm alias default 0.10
```

#### Ubuntu / Debian

The following commands will install the prerequisites.

```bash
sudo apt-get install build-essential cmake git python2.7 node.js
```


### Development Setup

```bash
git clone git@github.com:pwnall/w3hear-js.git
# If SSH is blocked, use the following alternative.
#     git clone https://github.com/pwnall/w3hear-js.git
cd w3hear-js
git submodule init
git submodule update
npm install -g coffee-script
npm install
./script/build_fastcomp.sh
./script/build_sphinx.sh
```

A NPM package that we depend on uses the gulp ES6 transpiler, so it needs its
development dependencies and pre-packaging build step.

```bash
cd node_modules/web-audio-api
npm install
```


### Running tests

In order to get full coverage, we must run the test suite in
[node.js](https://nodejs.org),
[Google Chrome](https://www.google.com/chrome/) and
[Mozilla Firefox](https://www.mozilla.com/firefox/)

```bash
cake test
cake webtest
BROWSER=firefox cake webtest
```

At the time of this writing, only Firefox has a spec-compliant implementation
of the Web Audio API. The tests use some hacks to make up for issues in Chrome.

We currently only run unit tests for the Web Worker code in node.js, mostly due
to convenience. It is possible to load these tests in a Web worker, but that
requires some non-trivial infrastructure changes.


## Copyright

This project is Copyright (c) 2014 Victor Costan and Staphany Park, and
distributed under the MIT License.
