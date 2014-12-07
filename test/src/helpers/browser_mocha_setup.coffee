if typeof window isnt 'undefined'
  mocha.setup(
      ui: 'bdd', slow: 150, timeout: 5000, bail: false, ignoreLeaks: false)
else
  # Web Workers.
  mocha.setup(
      ui: 'bdd', slow: 150, timeout: 5000, bail: false,
      reporter: 'post-message', ignoreLeaks: false)
