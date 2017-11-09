#[
    Manages FPS of window

    Made by Earl Kennedy
    https://github.com/Mnenmenth
    https://mnenmenth.com
]#

import sdl2.sdl
type
    FPSManager* = ref object of RootObj
        counter, fps, maxfps: int
        timer: sdl.TimerID
        delta: float
        ticks, freq: uint64

proc newFpsManager*(maxfps: int): FPSManager =
    FPSManager(counter: 0, fps: 0, maxfps: maxfps, timer: 0, delta: 0.0, ticks: sdl.getPerformanceCounter(), freq: sdl.getPerformanceFrequency())

method fps*(manager: FPSManager): int {.base.}  = return manager.fps

method count*(manager: FPSManager) {.base.}  = inc(manager.counter)

method manage*(manager: FPSManager) {.base.} =
    manager.count()
    let spare = uint32(1000 / manager.maxfps) -
        1000'u32 * uint32((sdl.getPerformanceCounter() - manager.ticks).float / manager.freq.float)
    if spare > 0'u32:
        sdl.delay(spare)
    
    manager.delta = (sdl.getPerformanceCounter() - manager.ticks).float / manager.freq.float
    manager.ticks = sdl.getPerformanceCounter()