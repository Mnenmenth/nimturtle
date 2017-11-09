# Package

version       = "0.2.4"
author        = "Earl Kennedy"
description   = "Turtle Graphics using SDL"
license       = "MIT"

srcDir        = "src"
backend       = "c"

skipDirs      = @["test"]
skipExt       = @["exe"]  

# Dependencies

requires "nim >= 0.17.2"
requires "sdl2_nim"

import distros
foreignDep "sdl2"

task test, "Run turtle test - debug":
    exec "nimble testd"
task testd, "Run turtle test - debug":
    exec "nim c --d:debug --lineDir:on --debuginfo --run src/test/test.nim"
task testr, "Run turtle test - release":
    exec "nim c --d:release --opt:size --run src/test/test.nim"