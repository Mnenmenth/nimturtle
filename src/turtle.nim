import math
import sdl2.sdl

import turtle/private/graph
import turtle/private/triangle
from turtle/private/turtle_global import g
import turtle/private/frame_manager
import turtle/private/line

let TURTLE_SIZE: graph.Dimension = graph.Dimension(width: 2, height: 4)

const
    Title = "Turtle"
    Width = 1270
    Height = 720
    WindowFlags = 0
    RenderFlags = 0

g.parentDim = graph.Dimension(width: Width, height: Height)

type
    Turtle* = ref object of RootObj
        shape: Triangle
        pos: graph.Coordinate
        heading: float
        penstatus: bool
        color: tuple[r: int, g: int, b: int]
        lines: seq[Line]     
    App = ref object of RootObj
        window*: sdl.Window
        renderer*: sdl.Renderer

var 
    app = App(window: nil, renderer: nil)
    done = false
    pressed: seq[sdl.Keycode] = @[]
    turtles: seq[Turtle] = @[]

proc newTurtle*(): Turtle =
    result = Turtle(
        shape: Triangle(vert1: graph.Coordinate(x: 0, y: 0), vert2: graph.Coordinate(x: -TURTLE_SIZE.height.float, y: TURTLE_SIZE.width.float), vert3: graph.Coordinate(x: -TURTLE_SIZE.height.float, y: -TURTLE_SIZE.width.float)),
        pos: graph.Coordinate(x: 0, y: 0),
        heading: 90.0,
        penstatus: true,
        color: (0, 0, 0),
        lines: @[]
    )
    turtles.add(result)

proc setpos*(turtle: Turtle, x, y: float) =

    let oldx = turtle.pos.x
    let oldy = turtle.pos.y

    if turtle.penstatus:
        let line = Line(lineStart: graph.Coordinate(x: oldx, y: oldy), lineEnd: graph.Coordinate(x: x, y: y), color: turtle.color)
        turtle.lines.add(line)

    turtle.pos = graph.Coordinate(x: x, y: y)
    
    turtle.shape.vert1.x = x
    turtle.shape.vert1.y = y

    turtle.shape.vert2.x = x - TURTLE_SIZE.height.float
    turtle.shape.vert2.y = y + TURTLE_SIZE.width.float

    turtle.shape.vert3.x = x - TURTLE_SIZE.height.float
    turtle.shape.vert3.y = y - TURTLE_SIZE.width.float
    

proc getpos*(turtle: Turtle): tuple[x: float, y: float] =
    turtle.pos.astuple()

proc setheading*(turtle: Turtle, value: float) =
    turtle.heading = value
    if turtle.heading < 0:
        while turtle.heading < 0:
            turtle.heading += 360
    elif turtle.heading > 360:
        while turtle.heading > 360:
            turtle.heading -= 360

proc getheading*(turtle: Turtle): float =
    turtle.heading

proc getcolor*(turtle: Turtle): tuple[r: int, g: int, b: int] =
    turtle.color

proc setcolor*(turtle: Turtle, r: int, g: int, b: int) =
    turtle.color.r = r
    turtle.color.g = g

proc move_turtle(turtle: Turtle, dist: float) =
    let x = turtle.shape.vert1.x.float + dist * cos(turtle.heading * (PI/180))
    let y = turtle.shape.vert1.y.float + dist * sin(turtle.heading * (PI/180))

    turtle.setpos(x, y)

proc fd*(turtle: Turtle, dist: float) =
    turtle.move_turtle(dist)

proc lt*(turtle: Turtle, angle: float) =
    turtle.setheading(turtle.heading+angle)
    turtle.shape.rotate(turtle.heading)    

proc rt*(turtle: Turtle, angle: float) =
    turtle.setheading(turtle.heading-angle)
    turtle.shape.rotate(turtle.heading)    

proc pu*(turtle: Turtle) =
    turtle.penstatus = false

proc pd*(turtle: Turtle) = 
    turtle.penstatus = true

proc draw*(turtle: Turtle, renderer: sdl.Renderer) =
    #[var turtle_shape = Triangle(vert1: graph.Coordinate(x: 0, y: 0), vert2: graph.Coordinate(x: 0, y: 0), vert3: graph.Coordinate(x: 0, y: 0))
    deepCopy(turtle_shape, turtle.shape)
    turtle_shape.rotate(turtle.heading)
    renderer.drawTriangle(turtle_shape)]#
    #turtle.shape.rotate(turtle.heading)
    renderer.drawTriangle(turtle.shape)

proc init(app: App): bool =
    if sdl.init(sdl.InitVideo or sdl.InitTimer) != 0:
        echo "Error: Cannot init sdl: ", sdl.getError()
        return false

    app.window = sdl.createWindow(
        Title,
        sdl.WindowPosCentered,
        sdl.WindowPosCentered,
        Width,
        Height,
        WindowFlags
    )
    if app.window == nil:
        echo "Error: Cannot open window: ", sdl.getError()
        return false

    app.renderer = sdl.createRenderer(app.window, -1, RenderFlags)
    if app.renderer == nil:
        echo "Error: Cannot open window: ", sdl.getError()
        return false

    if app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF) != 0:
        echo "Error: Cannot set draw color" , sdl.getError()
        return false

    var mode: DisplayMode
    
    discard sdl.getDisplayMode(0, 0, addr(mode))

    let scale = 5/8

    let w = int(round(mode.h.float * scale))
    let h = int(round(mode.h.float * scale))

    app.window.setWindowSize(w, h)
    app.window.setWindowPosition(sdl.WindowPosCentered, sdl.WindowPosCentered)
    g.parentDim = graph.Dimension(width: w, height: h)

    echo "SDL init successfully"
    return true

proc exit(app: App) = 
    app.renderer.destroyRenderer()
    app.window.destroyWindow()
    sdl.quit()
    echo "SDL shutdown complete"

proc events(pressed: var seq[sdl.Keycode]): bool =
    result = false
    var e: sdl.Event
    if pressed != nil:
        pressed = @[]
    
    while sdl.pollEvent(addr(e)) != 0:
        if e.kind == sdl.Quit:
            return true
        elif e.kind == sdl.KeyDown:
            if pressed != nil:
                pressed.add(e.key.keysym.sym)
            if e.key.keysym.sym == sdl.K_ESCAPE:
                return true

proc mainloop*() =

    const FPS: int = 100
    var 
        fpsMgr = newFpsManager()
        delta = 0.0
        ticks: uint64
        freq = sdl.getPerformanceFrequency()

    ticks = sdl.getPerformanceCounter()

    if init(app):

        if app.renderer.renderClear() != 0:
            echo "Warning: Can't clear screen: ", sdl.getError()

        while not done:
            discard app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF)
            discard app.renderer.renderClear()

            discard app.renderer.setRenderDrawColor(0, 0, 0, 0)

            for c in turtles:
                for line in c.lines:
                    discard app.renderer.setRenderDrawColor(uint8(line.color.r), uint8(line.color.g), uint8(line.color.b), 0)                                        
                    line.draw(app.renderer)
                discard app.renderer.setRenderDrawColor(0, 0, 0, 0)                    
                c.draw(app.renderer)

            app.renderer.renderPresent()
            done = events(pressed)

            fpsMgr.count()
            let spare = uint32(1000 / FPS) -
                1000'u32 * uint32((sdl.getPerformanceCounter() - ticks).float / freq.float)
            if spare > 0'u32:
                sdl.delay(spare)
            
            delta = (sdl.getPerformanceCounter() - ticks).float / freq.float
            ticks = sdl.getPerformanceCounter()

    #free(fpsMgr)            
    exit(app)