#[
    Turtle Graphics implementation in Nim using SDL2

    Made by Earl Kennedy
    https://github.com/Mnenmenth
    https://mnenmenth.com
]#

import math
import strutils
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

type
    Turtle* = ref object of RootObj
        shape: Triangle
        pos: graph.Coordinate
        heading: float
        penstatus: bool
        color: tuple[r: int, g: int, b: int]
        movements: seq[Movement]
        speed: int
    App = ref object of RootObj
        window*: sdl.Window
        renderer*: sdl.Renderer

var 
    app = App(window: nil, renderer: nil)
    done = false
    pressed: seq[sdl.Keycode] = @[]
    turtles: seq[Turtle] = @[]
    sdlInit: bool = false
    skipAnimation: bool = false

proc setSkipAnimation*(skip: bool) = skipAnimation = skip

const FPS: int = 60
var fpsMgr = newFpsManager(FPS)
let g: Graph = newGraph(newDimension(Width, Height), 100, 100, 100, 100)
    
proc updateScreen(newManager: bool)

proc newTurtle*(): Turtle =
    result = Turtle(
        shape: newTriangle(newCoordinate(0, 0), newCoordinate(-TURTLE_SIZE.height.float, TURTLE_SIZE.width.float), newCoordinate(-TURTLE_SIZE.height.float, -TURTLE_SIZE.width.float)),
        pos: newCoordinate(0, 0),
        heading: 0.0,
        penstatus: true,
        color: (0, 0, 0),
        movements: @[],
        speed: 1
    )
    turtles.add(result)

method updateRot(turtle: Turtle) {.base.} =
    turtle.shape.rotate(turtle.heading)

method setPos(turtle: Turtle, x, y: float) {.base.} =
    turtle.pos = newCoordinate(x, y)
    
    turtle.shape.vert1.x = x
    turtle.shape.vert1.y = y

    turtle.shape.vert2.x = x - TURTLE_SIZE.height.float
    turtle.shape.vert2.y = y + TURTLE_SIZE.width.float

    turtle.shape.vert3.x = x - TURTLE_SIZE.height.float
    turtle.shape.vert3.y = y - TURTLE_SIZE.width.float
    
    turtle.updateRot()

method setPos(turtle: Turtle, pos: tuple[x, y: float]) {.base.} =
    turtle.setPos(pos.x, pos.y)

method goto*(turtle: Turtle, x, y: float) {.base.} =

    let oldx = turtle.pos.x
    let oldy = turtle.pos.y

    let movement = newMovement(newLine((oldx, oldy), (x, y)), turtle.heading, turtle.color, turtle.penstatus, skipAnimation)
    turtle.movements.add(movement)

    turtle.setPos(x, y)

method goto*(turtle: Turtle, pos: tuple[x, y: float]) {.base.} =
    turtle.goto(pos.x, pos.y)

method getPos*(turtle: Turtle): tuple[x: float, y: float] {.base.} =
    turtle.pos.astuple()

method setHeading*(turtle: Turtle, value: float) {.base.} =
    turtle.heading = value
    if turtle.heading < 0:
        while turtle.heading < 0:
            turtle.heading += 360
    elif turtle.heading > 360:
        while turtle.heading > 360:
            turtle.heading -= 360

method getHeading*(turtle: Turtle): float {.base.} =
    turtle.heading

method getColor*(turtle: Turtle): tuple[r: int, g: int, b: int] {.base.} =
    turtle.color

method setColor*(turtle: Turtle, r: int, g: int, b: int) {.base.} =
    turtle.color.r = r
    turtle.color.g = g
    turtle.color.b = b

method getSpeed*(turtle: Turtle): int {.base.} =
    turtle.speed

method setSpeed*(turtle: Turtle, speed: int) {.base.} =
    turtle.speed = speed

method fd*(turtle: Turtle, dist: float) {.base.} = 
    let x = turtle.shape.vert1.x.float + dist * cos(turtle.heading * (PI/180))
    let y = turtle.shape.vert1.y.float + dist * sin(turtle.heading * (PI/180))

    let round_to: float = 4
    let roundnum = 10 * round_to

    let roundx = round(x * roundnum) / roundnum
    let roundy = round(y * roundnum) / roundnum

    turtle.goto(roundx, roundy)
    if not skipAnimation: updateScreen(newManager=true)

method forward*(turtle: Turtle, dist: float) {.base.} = 
    turtle.fd(dist)

method lt*(turtle: Turtle, angle: float) {.base.} =
    turtle.setHeading(turtle.heading+angle)
    turtle.updateRot()
    if not skipAnimation: updateScreen(newManager=true)

method leftTurn*(turtle: Turtle, angle: float) {.base.} =
    turtle.lt(angle)

method rt*(turtle: Turtle, angle: float) {.base.} =
    turtle.setHeading(turtle.heading-angle)
    turtle.updateRot()
    if not skipAnimation: updateScreen(newManager=true)

method rightTurn*(turtle: Turtle, angle: float) {.base.} =
    turtle.rt(angle)

method pu*(turtle: Turtle) {.base.} =
    turtle.penstatus = false

method penUp*(turtle: Turtle) {.base.} =
    turtle.pu()

method pd*(turtle: Turtle) {.base.} = 
    turtle.penstatus = true

method penDown*(turtle: Turtle) {.base.} =
    turtle.pd()

method draw(turtle: Turtle, renderer: sdl.Renderer) {.base.} =
    turtle.shape.drawTriangle(g, renderer)

method init(app: App): bool {.base.} =
    if sdlInit == false:
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
        sdlInit = true
    return true

method exit(app: App) {.base.} = 
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

proc updateScreen(newManager: bool) =    
    if init(app) and not done:
        if newManager:
            fpsMgr = newFpsManager(FPS)

        if app.renderer.renderClear() != 0:
            echo "Warning: Can't clear screen: ", sdl.getError()

        discard app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF)
        discard app.renderer.renderClear()
        discard app.renderer.setRenderDrawColor(0, 0, 0, 0)
        block update:
            for t in turtles:
                for m in t.movements:
                    if not m.animated:
                        let tempLine = newLine((m.line.lineStart.x, m.line.lineStart.y), (m.line.lineStart.x, m.line.lineStart.y))
                        let slopex = if m.line.lineEnd.x == m.line.lineStart.x: 0.0 else: (m.line.lineEnd.x - m.line.lineStart.x)/t.getSpeed.float
                        let slopey = if m.line.lineEnd.y == m.line.lineStart.y: 0.0 else: (m.line.lineEnd.y - m.line.lineStart.y)/t.getSpeed.float
                        let oldHeading = t.heading
                        t.heading = m.heading
                        t.updateRot()
                        let mx = m.line.lineEnd.x
                        let my = m.line.lineEnd.y
                        while (if slopex < 0: tempLine.lineEnd.x >= mx else: tempLine.lineEnd.x <= mx) and
                              (if slopey < 0: tempLine.lineEnd.y >= my else: tempLine.lineEnd.y <= my):
                            discard app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF)
                            discard app.renderer.renderClear()
                            discard app.renderer.setRenderDrawColor(0, 0, 0, 0)

                            t.setPos(tempLine.lineEnd.astuple)
                            
                            if m.visible:
                                discard app.renderer.setRenderDrawColor(uint8(m.color.r), uint8(m.color.g), uint8(m.color.b), 0)
                                tempLine.draw(g, app.renderer)

                            discard app.renderer.setRenderDrawColor(0, 0, 0, 0)
                            t.draw(app.renderer)

                            tempLine.lineEnd.x += slopex
                            tempLine.lineEnd.y += slopey

                            for t1 in turtles:
                                for m1 in t1.movements:
                                    if m1.animated and m1.visible:
                                        discard app.renderer.setRenderDrawColor(uint8(m1.color.r), uint8(m1.color.g), uint8(m1.color.b), 0)
                                        m1.draw(g, app.renderer)
                                        done = events(pressed)
                                        if done: break update
                                if t != t1: t1.draw(app.renderer)

                            app.renderer.renderPresent()
                            done = events(pressed)
                            if done: break update

                            fpsMgr.manage()

                        t.heading = oldHeading
                        t.setPos((m.line.lineEnd.x, m.line.lineEnd.y))
                        m.animated = true
                    elif m.visible:
                        discard app.renderer.setRenderDrawColor(uint8(m.color.r), uint8(m.color.g), uint8(m.color.b), 0)
                        m.draw(g, app.renderer)
                discard app.renderer.setRenderDrawColor(0, 0, 0, 0)
                t.draw(app.renderer)
            app.renderer.renderPresent()
            done = events(pressed)
            if done: break update

            fpsMgr.manage()
    elif init(app) and done:
        exit(app)
        quit("Terminated early by user input", 0)
    else:
        exit(app)
        quit("SDL could not init", -1)

proc finished*() =

    if init(app):
        updateScreen(newManager=true)
        while not done:
            updateScreen(false)

        exit(app)
    else:
        exit(app)
        quit("SDL could not init", -1)