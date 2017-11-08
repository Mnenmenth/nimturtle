# Package

version       = "0.1.2"
author        = "Earl Kennedy"
description   = "Turtle Graphics using SDL"
license       = "MIT"

srcDir        = "src"
#binDir        = "bin"
#bin           = @["turtle"]
backend       = "c"

skipDirs      = @["test"]
skipExt       = @["exe"]  

# Dependencies

requires "nim >= 0.17.2"
requires "sdl2_nim"

import distros
foreignDep "sdl2"

task test, "Run turtle test":
    exec "nim c -r src/test/test.nim"