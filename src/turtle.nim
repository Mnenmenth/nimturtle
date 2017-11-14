## Turtle Graphics implementation in Nim using SDL2
#                                                      
#  Made by Earl Kennedy                               
#  https://github.com/Mnenmenth                        
#  https://mnenmenth.com

import math
import strutils
import sdl2.sdl

import turtle/private/graph
import turtle/private/triangle
import turtle/private/frame_manager
import turtle/private/movement
import turtle/private/line

type
    Turtle* = ref object of RootObj
        ## Turtle type
        shape: Triangle
            # shape is the triangle that is graphically drawn to represent the turtle on the screen
        pos: graph.Coordinate
            # pos stores the position of the top vertice of the turtle shape
        heading: float 
            # heading stores the angular direction of the turtle (0-360 degrees)
        penStatus: bool 
            # penStatus stores the current state of the pen (up or down)
        color: tuple[r: int, g: int, b: int] 
            # color stores the rgb values of the current color of the turtle
        movements: seq[Movement] 
            # movements stores all of the movements made by the turtle
        speed: int 
            # speed stores the current speed of the turtle (lower value = faster)
    App = ref object of RootObj
        # Contains window and renderer for turtle graphics
        window*: sdl.Window 
            # window stores the window for drawing graphics
        renderer*: sdl.Renderer 
            # renderer stores the renderer for drawing graphics

const
    # Constants for sdl window
    Title = "Turtle"
    Width = 1270
    Height = 720
    WindowFlags = 0
    RenderFlags = 0
    FPS: int = 60

let 
    app = App(window: nil, renderer: nil)
    # New graph object for unit to pixel conversion
    g: Graph = newGraph(newDimension(Width, Height), 100, 100, 100, 100)
    # Size of turtle cursor (altitude and base of triangle)
    TURTLE_SIZE: Dimension = newDimension(2, 4)
var 
    # FPS Manager for graphics loop
    fpsMgr = newFpsManager(FPS)
    # Stores if graphics loop should quit
    done = false
    # The keys pressed in the event poll
    pressed: seq[sdl.Keycode] = @[]
    # Turtles created by user
    turtles: seq[Turtle] = @[]
    # Stores if sdl has been initialized
    sdlInit: bool = false
    # Stores if the graphics loop skip animating turtle movements
    skipAnimation: bool = false


proc setSkipAnimation*(skip: bool) =
    ## Set if animation for movement(s) should be skipped. 
    ## Only affects movements after set to false, and none after set back to true
    skipAnimation = skip

    
proc updateScreen(newManager: bool)

proc newTurtle*(): Turtle =
    ## Creates new turtle
    result = Turtle(
        # Define shape as triangle at (0, 0) with bottom vertices defined by TURTLE_SIZE
        shape: newTriangle(newCoordinate(0, 0), newCoordinate(-TURTLE_SIZE.height.float, TURTLE_SIZE.width.float), newCoordinate(-TURTLE_SIZE.height.float, -TURTLE_SIZE.width.float)),
        # Initial position of turtle is (0, 0)
        pos: newCoordinate(0, 0),
        # Initial heading of turtle is 0 degrees
        heading: 0.0,
        # Pen is down by default
        penstatus: true,
        # Color is black by default
        color: (0, 0, 0),
        # Turtle currently has no movements
        movements: @[],
        # Roughly a medium speed as default
        speed: 50
    )
    # Add the new turtle to the list of turtles
    turtles.add(result)

method updateRot(turtle: Turtle) {.base.} =
    ## Updates rotation of turtle shape
    turtle.shape.rotate(turtle.heading)

method setPos(turtle: Turtle, x, y: float) {.base.} =
    # Sets the position of the turtle
    # This method directly sets the position of the turtle 
    # and doesn't add a new movement, so it is private
    turtle.pos = newCoordinate(x, y)
    
    # Sets of position of turtle then adjusts
    # the two vertices that make up the base accordingly
    turtle.shape.vert1.x = x
    turtle.shape.vert1.y = y

    turtle.shape.vert2.x = x - TURTLE_SIZE.height.float
    turtle.shape.vert2.y = y + TURTLE_SIZE.width.float

    turtle.shape.vert3.x = x - TURTLE_SIZE.height.float
    turtle.shape.vert3.y = y - TURTLE_SIZE.width.float
    
    # After new position, 
    # update the rotation of the shape to the proper heading
    turtle.updateRot()

method setPos(turtle: Turtle, pos: tuple[x, y: float]) {.base.} =
    # Convenience method to allow tuples
    # instead of seperate values in function call
    turtle.setPos(pos.x, pos.y)

method goto*(turtle: Turtle, x, y: float) {.base.} =
    ## Go directly to new position

    # Save the current position of the turtle
    let oldx = turtle.pos.x
    let oldy = turtle.pos.y

    # Add new movement to list of turtle's movements
    let movement = newMovement(newLine((oldx, oldy), (x, y)), turtle.heading, turtle.color, turtle.penstatus, skipAnimation)
    turtle.movements.add(movement)

    # Apply transformation
    turtle.setPos(x, y)

method goto*(turtle: Turtle, pos: tuple[x, y: float]) {.base.} =
    ## Convenience method to allow tuples
    ## instead of seperate values in function call
    turtle.goto(pos.x, pos.y)

method getPos*(turtle: Turtle): tuple[x: float, y: float] {.base.} =
    ## Returns the current position of the turtle
    turtle.pos.astuple()

method setHeading*(turtle: Turtle, value: float) {.base.} =
    ## Set the heading of the turtle
    turtle.heading = value
    # Make sure the new heading is 0 > x < 360
    if turtle.heading < 0:
        while turtle.heading < 0:
            turtle.heading += 360
    elif turtle.heading > 360:
        while turtle.heading > 360:
            turtle.heading -= 360
    # Update rotation of turtle shape
    turtle.updateRot()

method getHeading*(turtle: Turtle): float {.base.} =
    ## Returns current heading of the turtle
    turtle.heading

method getColor*(turtle: Turtle): tuple[r: int, g: int, b: int] {.base.} =
    ## Returns current color of the turtle
    turtle.color

method setColor*(turtle: Turtle, r: int, g: int, b: int) {.base.} =
    ## Set the color of the turtle
    turtle.color.r = r
    turtle.color.g = g
    turtle.color.b = b

method setColor*(turtle: Turtle, color: tuple[r: int, g: int, b: int]) {.base.} =
    ## Convenience method for setColor to allow tuples
    turtle.color.r = color.r
    turtle.color.g = color.g
    turtle.color.b = color.b

method getSpeed*(turtle: Turtle): int {.base.} =
    ## Returns the current speed of the turtle
    turtle.speed

method setSpeed*(turtle: Turtle, speed: int) {.base.} =
    ## Set the speed of the turtle
    turtle.speed = speed

method fd*(turtle: Turtle, dist: float) {.base.} = 
    ## Moves the turtle fd by given distance based on current heading

    # Calculate new x and y based on heading
    let x = turtle.shape.vert1.x.float + dist * cos(turtle.heading * (PI/180))
    let y = turtle.shape.vert1.y.float + dist * sin(turtle.heading * (PI/180))

    # Apply new position
    turtle.goto(x, y)

    # If skipAnimation is false, animate the movement
    if not skipAnimation: updateScreen(newManager=true)

method forward*(turtle: Turtle, dist: float) {.base.} = 
    ## Alias method of fd
    turtle.fd(dist)

method lt*(turtle: Turtle, angle: float) {.base.} =
    ## Turns the turtle left by angle

    # Add the angle to the current heading
    turtle.setHeading(turtle.heading+angle)
    # If skipAnimation is false, animate the movement
    if not skipAnimation: updateScreen(newManager=true)

method leftTurn*(turtle: Turtle, angle: float) {.base.} =
    # Alias method for lt()
    turtle.lt(angle)

method rt*(turtle: Turtle, angle: float) {.base.} =
    ## Turns the turtle right by angle

    # Subtracts angle from the current heading
    turtle.setHeading(turtle.heading-angle)

    # If skipAnimation is false, animate the movement
    if not skipAnimation: updateScreen(newManager=true)

method rightTurn*(turtle: Turtle, angle: float) {.base.} =
    ## Alias method for rt()
    turtle.rt(angle)

method pu*(turtle: Turtle) {.base.} =
    ## Set pen to up position
    turtle.penstatus = false

method penUp*(turtle: Turtle) {.base.} =
    ## Alias method for pu()
    turtle.pu()

method pd*(turtle: Turtle) {.base.} =
    ## Set pen to down position
    turtle.penstatus = true

method penDown*(turtle: Turtle) {.base.} =
    ## Alias method for pd()
    turtle.pd()

method draw(turtle: Turtle, renderer: sdl.Renderer) {.base.} =
    # Draw the turtle shape onto the screen
    turtle.shape.drawTriangle(true, g, renderer)

method init(app: App): bool {.base.} =
    # Only initialize sdl if it has not already been initialized
    if sdlInit == false:
        # Initialize sdl
        if sdl.init(sdl.InitVideo or sdl.InitTimer) != 0:
            # Print error if sdl cannot Initalize
            echo "Error: Cannot init sdl: ", sdl.getError()
            return false

        # Create new window
        app.window = sdl.createWindow(
            Title,
            sdl.WindowPosCentered,
            sdl.WindowPosCentered,
            Width,
            Height,
            WindowFlags
        )

        # Check if window was created successfully
        if app.window == nil:
            # If window failed creation, print out the error
            echo "Error: Cannot open window: ", sdl.getError()
            return false

        # Create the renderer for the window
        app.renderer = sdl.createRenderer(app.window, -1, RenderFlags)
        # Check if the renderer was created successfully
        if app.renderer == nil:
            # If renderer failed creation, print out the error
            echo "Error: Cannot open window: ", sdl.getError()
            return false

        # Check if the renderer is able to set the color for drawing
        if app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF) != 0:
            # If renderer is unable to set draw color, print out the error
            echo "Error: Cannot set draw color" , sdl.getError()
            return false

        # Get the information about the current modeling the window is in
        var mode: DisplayMode
        
        discard sdl.getDisplayMode(0, 0, addr(mode))

        # The window should be 5/8 the resolution of the host monitor
        let scale = 5/8

        # Apply the scale
        let w = int(round(mode.h.float * scale))
        let h = int(round(mode.h.float * scale))

        # Set the window size
        app.window.setWindowSize(w, h)
        # Set the window position to be centered on the screen
        app.window.setWindowPosition(sdl.WindowPosCentered, sdl.WindowPosCentered)
        # Set the parent dimension of the conversion graph to the new size
        g.parentDim = newDimension(w, h)

        echo "SDL init successfully"
        sdlInit = true
    return true

method exit(app: App) {.base.} = 
    # Destroy window and renderer, and quit sdl
    app.renderer.destroyRenderer()
    app.window.destroyWindow()
    sdl.quit()
    echo "SDL shutdown complete"

proc events(pressed: var seq[sdl.Keycode]): bool =
    # Gathers input events. Returns if program should quit

    # False by default
    result = false
    # Current event
    var e: sdl.Event
    # Empty last list of pressed keys
    if pressed != nil:
        pressed = @[]
    
    while sdl.pollEvent(addr(e)) != 0:
        # If the window receives the quit signal, then exit
        if e.kind == sdl.Quit:
            return true
        elif e.kind == sdl.KeyDown:
            # If a key is pressed, add it to the list of pressed keys
            if pressed != nil:
                pressed.add(e.key.keysym.sym)
            # If escape is pressed, then exit
            if e.key.keysym.sym == sdl.K_ESCAPE:
                return true

proc updateScreen(newManager: bool) =
    # Renders everything to the screen
    # newManager delegates if a new FPSManager is needed
    # If updateScreen is called somewhere other than the main loop,
    # then the time between calls of updateScreen causes the FPsManager
    # hang the program

    # If everything has properly initialized and the program shouldn't quit, then contiue with drawing  
    if init(app) and not done:
        # Create a new FPSManager if needed
        if newManager:
            fpsMgr = newFpsManager(FPS)

        # Test if the screen can be cleared
        if app.renderer.renderClear() != 0:
            # Print out error if screen cannot be cleared
            echo "Warning: Can't clear screen: ", sdl.getError()

        # Set the color for the blank frame
        discard app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF)
        # Clear the screen
        discard app.renderer.renderClear()
        # Set default draw color to black
        discard app.renderer.setRenderDrawColor(0, 0, 0, 0)

        # Block so that each loop doesn't have to be 
        # individually broken if user requests termination
        block update:
            # Loop through each turtle
            for t in turtles:
                # Loop through each movement in the turtle
                for m in t.movements:
                    # If the movement has not already been animated
                    if not m.animated:
                        # Create a new line that starts and ends
                        # at the movement start position
                        # This is the line that will be incremented to create the animation
                        let tempLine = newLine((m.line.lineStart.x, m.line.lineStart.y), (m.line.lineStart.x, m.line.lineStart.y))
                        # Get the slope on the axes. If the end and start are the same, slope is zero
                        let slopex = if m.line.lineEnd.x == m.line.lineStart.x: 0.0 else: (m.line.lineEnd.x - m.line.lineStart.x)/t.getSpeed.float
                        let slopey = if m.line.lineEnd.y == m.line.lineStart.y: 0.0 else: (m.line.lineEnd.y - m.line.lineStart.y)/t.getSpeed.float
                        # Save the current heading to reapply it after the animation, 
                        # set the turtle heading to the movement heading,
                        # and update the orientation of the shape
                        let oldHeading = t.heading
                        t.heading = m.heading
                        t.updateRot()
                        # Smaller variable names for movement x and y
                        let mx = m.line.lineEnd.x
                        let my = m.line.lineEnd.y
                        # While the temporary animation line's end has not reached the end of the movement,
                        # incremend the end of the line by the slope
                        while (if slopex < 0: tempLine.lineEnd.x >= mx else: tempLine.lineEnd.x <= mx) and
                              (if slopey < 0: tempLine.lineEnd.y >= my else: tempLine.lineEnd.y <= my):
                            # Set render colors and draw screen
                            discard app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF)
                            discard app.renderer.renderClear()
                            discard app.renderer.setRenderDrawColor(0, 0, 0, 0)

                            # Set the position of the turtle to the 
                            # current end of the animation line
                            t.setPos(tempLine.lineEnd.astuple)
                            
                            # If the pen was down during the movement, then draw it
                            if m.visible:
                                # Apply the color that the turtle was during the time the movement occured
                                discard app.renderer.setRenderDrawColor(uint8(m.color.r), uint8(m.color.g), uint8(m.color.b), 0)
                                # Draw the movement using the unit conversion graph and window renderer
                                tempLine.draw(g, app.renderer)

                            # Set color back to black then draw the turtle
                            discard app.renderer.setRenderDrawColor(0, 0, 0, 0)
                            t.draw(app.renderer)

                            # Increment line end by slope
                            tempLine.lineEnd.x += slopex
                            tempLine.lineEnd.y += slopey

                            # Make sure everything else currently on the screen, stays on the screen
                            for t1 in turtles:
                                for m1 in t1.movements:
                                    # Draw all previous movements
                                    # Don't draw the current movement, and only draw if the movement
                                    # is visible and already has been animated
                                    if m1.animated and m1.visible and m1 != m:
                                        # Apply the appropriate colors and draw
                                        discard app.renderer.setRenderDrawColor(uint8(m1.color.r), uint8(m1.color.g), uint8(m1.color.b), 0)
                                        m1.draw(g, app.renderer)
                                        # Test if the user has requested program termination
                                        done = events(pressed)
                                        # If the user has, then break all current loops
                                        if done: break update
                                # Don't draw the same turtle twice
                                if t != t1: t1.draw(app.renderer)

                            # Apply all previous draw commands
                            app.renderer.renderPresent()
                            # Test if the user has requested program termination
                            done = events(pressed)
                            # If the user has, then break all current loops
                            if done: break update

                            # Make sure the fps is limited
                            fpsMgr.manage()

                        # Return turtle to original heading
                        t.heading = oldHeading
                        # Apply turtle to true end of line
                        # This is to prevent any inaccuricies of the tempLine position
                        # from floating point errors 
                        t.setPos((m.line.lineEnd.x, m.line.lineEnd.y))
                        # Animation is completed
                        m.animated = true
                    # If the movement has already been animated and is visible,
                    # then draw the movement
                    elif m.visible:
                        # Set the color
                        discard app.renderer.setRenderDrawColor(uint8(m.color.r), uint8(m.color.g), uint8(m.color.b), 0)
                        # Draw the movement
                        m.draw(g, app.renderer)
                # Set the color to black
                discard app.renderer.setRenderDrawColor(0, 0, 0, 0)
                # Draw the turtle
                t.draw(app.renderer)
            # Render all previous draw commands
            app.renderer.renderPresent()
            # Test if the user has requested program termination
            done = events(pressed)
            # If the user has, then break all current loops
            if done: break update

            # Make sure fps is limited
            fpsMgr.manage()
    # If sdl was properly intialized, but user requested
    # termination, then successfully exit
    elif init(app) and done:
        exit(app)
        quit("Terminated early by user input", 0)
    # If sdl did not initialize properly, then exit with error
    else:
        exit(app)
        quit("SDL could not init", -1)

proc finished*() =
    ## Called after all turtle movements, rotations, etc. \
    ## Runs update loop at end so window doesn't freeze

    # If sdl was initialized properly, then update the screen
    # until the user requests terminationn
    if init(app):
        updateScreen(newManager=true)
        while not done:
            updateScreen(false)

        exit(app)
    # Otherwise, exit with error
    else:
        exit(app)
        quit("SDL could not init", -1)