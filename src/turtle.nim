import math
import sdl2.sdl

import turtle/private/graph
import turtle/private/triangle
import turtle/private/frame_manager
import turtle/private/movement
import turtle/private/line

let TURTLE_SIZE: Dimension = newDimension(2, 4)

const
    Title = "Turtle"
    Width = 1270
    Height = 720
    WindowFlags = 0
    RenderFlags = 0

let g: Graph = newGraph(newDimension(Width, Height), 100, 100, 100, 100)

type
    Turtle* = ref object of RootObj
        shape: Triangle
        pos: graph.Coordinate
        heading: float
        penstatus: bool
        color: tuple[r: int, g: int, b: int]
        movements: seq[Movement]     
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
        shape: newTriangle(newCoordinate(0, 0), newCoordinate(-TURTLE_SIZE.height.float, TURTLE_SIZE.width.float), newCoordinate(-TURTLE_SIZE.height.float, -TURTLE_SIZE.width.float)),
        pos: newCoordinate(0, 0),
        heading: 0.0,
        penstatus: true,
        color: (0, 0, 0),
        movements: @[]
    )
    turtles.add(result)

proc update_rot(turtle: Turtle) =
    turtle.shape.rotate(turtle.heading)

proc setpos*(turtle: Turtle, x, y: float) =

    let oldx = turtle.pos.x
    let oldy = turtle.pos.y

    let movement = newMovement(newLine((oldx, oldy), (x ,y)), turtle.color, turtle.penstatus)
    turtle.movements.add(movement)

    turtle.pos = newCoordinate(x, y)
    
    turtle.shape.vert1.x = x
    turtle.shape.vert1.y = y

    turtle.shape.vert2.x = x - TURTLE_SIZE.height.float
    turtle.shape.vert2.y = y + TURTLE_SIZE.width.float

    turtle.shape.vert3.x = x - TURTLE_SIZE.height.float
    turtle.shape.vert3.y = y - TURTLE_SIZE.width.float
    
    turtle.update_rot()

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
    turtle.update_rot()    

proc rt*(turtle: Turtle, angle: float) =
    turtle.setheading(turtle.heading-angle)
    turtle.update_rot()    

proc pu*(turtle: Turtle) =
    turtle.penstatus = false

proc pd*(turtle: Turtle) = 
    turtle.penstatus = true

proc draw*(turtle: Turtle, renderer: sdl.Renderer) =
    turtle.shape.drawTriangle(g, renderer)

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
    g.parentDim = newDimension(w, h)

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

            for t in turtles:
                for m in t.movements:
                    if m.visible:
                        discard app.renderer.setRenderDrawColor(uint8(m.color.r), uint8(m.color.g), uint8(m.color.b), 0)                                        
                        m.draw(g, app.renderer)
                discard app.renderer.setRenderDrawColor(0, 0, 0, 0)                    
                t.draw(app.renderer)

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