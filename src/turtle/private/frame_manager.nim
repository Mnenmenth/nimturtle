import sdl2.sdl
type
    FPSManager* = ref object of RootObj
        counter, fps, maxfps: int
        timer: sdl.TimerID
        delta: float
        ticks, freq: uint64

proc fpsTimer*(interval: uint32, param: pointer): uint32 {.cdecl.} =
    let manager = cast[FPSManager](param)
    manager.fps = manager.counter
    manager.counter = 0
    return interval

proc newFpsManager*(maxfps: int): FPSManager =
    FPSManager(counter: 0, fps: 0, maxfps: maxfps, timer: 0, delta: 0.0, ticks: sdl.getPerformanceCounter(), freq: sdl.getPerformanceFrequency())

proc free*(manager: FPSManager) =
    discard sdl.removeTimer(manager.timer)
    manager.timer = 0

proc fps*(manager: FPSManager): int {.inline.} = return manager.fps

proc start*(manager: FPSManager) =
    manager.timer = sdl.addTimer(1000, fpsTimer, cast[pointer](manager))

proc count*(manager: FPSManager) {.inline.} = inc(manager.counter)

proc manage*(manager: FPSManager) =
    manager.count()
    let spare = uint32(1000 / manager.maxfps) -
        1000'u32 * uint32((sdl.getPerformanceCounter() - manager.ticks).float / manager.freq.float)
    if spare > 0'u32:
        sdl.delay(spare)
    
    manager.delta = (sdl.getPerformanceCounter() - manager.ticks).float / manager.freq.float
    manager.ticks = sdl.getPerformanceCounter()