import sdl2.sdl
type
    FPSManager* = ref object of RootObj
        counter, fps: int
        timer: sdl.TimerID

proc fpsTimer*(interval: uint32, param: pointer): uint32 {.cdecl.} =
    let obj = cast[FPSManager](param)
    obj.fps = obj.counter
    obj.counter = 0
    return interval

proc newFpsManager*(): FPSManager = FPSManager(counter: 0, fps: 0, timer: 0)

proc free*(obj: FPSManager) =
    discard sdl.removeTimer(obj.timer)
    obj.timer = 0

proc fps*(obj: FPSManager): int {.inline.} = return obj.fps

proc start*(obj: FPSManager) =
    obj.timer = sdl.addTimer(1000, fpsTimer, cast[pointer](obj))

proc count*(obj: FPSManager) {.inline.} = inc(obj.counter)

